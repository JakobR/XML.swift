import libxml2

public enum XPathErrorCode: Int {
    case UnknownError = -1
    /// Everything's fine, this is not actually an error.
    case Ok = 0                         // XPATH_EXPRESSION_OK
    case NumberError                    // XPATH_NUMBER_ERROR
    case UnfinishedLiteralError         // XPATH_UNFINISHED_LITERAL_ERROR
    case StartLiteralError              // XPATH_START_LITERAL_ERROR
    case VariableReferenceError         // XPATH_VARIABLE_REF_ERROR
    case UndefinedVariable              // XPATH_UNDEF_VARIABLE_ERROR
    case InvalidPredicate               // XPATH_INVALID_PREDICATE_ERROR
    case ExpressionError                // XPATH_EXPR_ERROR
    case UnclosedBrace                  // XPATH_UNCLOSED_ERROR
    case UnknownFunction                // XPATH_UNKNOWN_FUNC_ERROR
    case InvalidOperand                 // XPATH_INVALID_OPERAND
    case InvalidType                    // XPATH_INVALID_TYPE
    case InvalidArity                   // XPATH_INVALID_ARITY
    case InvalidContextSize             // XPATH_INVALID_CTXT_SIZE
    case InvalidContextPosition         // XPATH_INVALID_CTXT_POSITION
    case MemoryError                    // XPATH_MEMORY_ERROR
    case SyntaxError                    // XPTR_SYNTAX_ERROR
    case ResourceError                  // XPTR_RESOURCE_ERROR
    case SubResourceError               // XPTR_SUB_RESOURCE_ERROR
    case UndefinedNamespacePrefix       // XPATH_UNDEF_PREFIX_ERROR
    case EncodingError                  // XPATH_ENCODING_ERROR
    case InvalidCharacter               // XPATH_INVALID_CHAR_ERROR
    case InvalidContext                 // XPATH_INVALID_CTXT
    case StackUsageError                // XPATH_STACK_ERROR
    case ForbiddenVariable              // XPATH_FORBID_VARIABLE_ERROR

    public var message: String {
        // XPath error messages, in order of the error codes
        //
        // Due to a bug, libxml2 doesn't give us access to the error message…
        // See https://bugzilla.gnome.org/show_bug.cgi?id=340729
        switch self {
        case .UnknownError:             return "?? Unknown error ??"
        case .Ok:                       return "Ok"
        case .NumberError:              return "Number encoding"
        case .UnfinishedLiteralError:   return "Unfinished literal"
        case .StartLiteralError:        return "Start of literal"
        case .VariableReferenceError:   return "Expected $ for variable reference"
        case .UndefinedVariable:        return "Undefined variable"
        case .InvalidPredicate:         return "Invalid predicate"
        case .ExpressionError:          return "Invalid expression"
        case .UnclosedBrace:            return "Missing closing curly brace"
        case .UnknownFunction:          return "Unregistered function"
        case .InvalidOperand:           return "Invalid operand"
        case .InvalidType:              return "Invalid type"
        case .InvalidArity:             return "Invalid number of arguments"
        case .InvalidContextSize:       return "Invalid context size"
        case .InvalidContextPosition:   return "Invalid context position"
        case .MemoryError:              return "Memory allocation error"
        case .SyntaxError:              return "Syntax error"
        case .ResourceError:            return "Resource error"
        case .SubResourceError:         return "Sub resource error"
        case .UndefinedNamespacePrefix: return "Undefined namespace prefix"
        case .EncodingError:            return "Encoding error"
        case .InvalidCharacter:         return "Char out of XML range"
        case .InvalidContext:           return "Invalid or incomplete context"
        case .StackUsageError:          return "Stack usage error"
        case .ForbiddenVariable:        return "Forbidden variable"
        }
    }
}

public struct XPathError: ErrorType {
    public let code: XPathErrorCode

    /// The error message as human-readable string.
    public var message: String {
        return "XPath error: " + code.message
        // TODO: Return info in str1
        // TODO: Also show error position, like libxml2 does (Maybe pass a more complex error type, with similar info as xmlError?)
    }

    /// The previous error, if multiple were collected during a single use of an XPathContext.
    public var previous: XPathError? { return previousBox?.value }
    private let previousBox: Box<XPathError>?

    /// Create an XPathError from a libxml2 error.
    /// - Parameter xmlError: A pointer to a libxml2 error. Pass nil to create an "unknown error".
    /// - Parameter previous: The previous error, if multiple are collected during a single use of an XPathContext.
    init(xmlError error: xmlErrorPtr, previous: XPathError? = nil) {
        self.previousBox = previous.map { Box($0) }
        if error != nil {
            let localCode = Int(error.memory.code) - Int(XML_XPATH_EXPRESSION_OK.rawValue) + Int(XPATH_EXPRESSION_OK.rawValue)
            code = XPathErrorCode(rawValue: localCode) ?? .UnknownError
        } else {
            code = .UnknownError
        }
    }
}

private class XPathContext {
    private let ptr: xmlXPathContextPtr
    private var error: XPathError? = nil

    private init(_doc: xmlDocPtr) throws {
        ptr = xmlXPathNewContext(_doc);
        guard ptr != nil else { throw Error.MemoryError }
        assert(ptr.memory.doc == _doc);

        // Set up error handling
        ptr.memory.userData = UnsafeMutablePointer<Void>(Unmanaged.passUnretained(self).toOpaque())
        ptr.memory.error = { (userData, error: xmlErrorPtr) in
            assert(userData != nil)
            let context = Unmanaged<XPathContext>.fromOpaque(COpaquePointer(userData)).takeUnretainedValue()
            context.error = XPathError(xmlError: error, previous: context.error)
        }
    }

    /// Create an XPathContext with a NULL document.
    convenience init() throws {
        try self.init(_doc: nil);
    }

    convenience init(node: Node) throws {
        try self.init(_doc: node.doc.ptr)
        ptr.memory.node = node.ptr
    }

    deinit {
        xmlXPathFreeContext(ptr);
    }

    func grabAndResetError() -> XPathError? {
        defer { error = nil }
        return error
    }

}

/// Represents a compiled XPath expression
public class XPath {
    private let ptr: xmlXPathCompExprPtr

    public init(_ expression: String, namespaces: [String:String] = [:]) throws {
        // TODO: Namespaces, variables, custom functions
        // (when adding this, we should probably re-use the XPathContext. (which makes this object very thread-unsafe, but then again, how thread-safe is the rest of this wrapper?))
        // Solution for thread-unsafety:
        // Provide a "copy" method that copies the context. (the xmlXPathCompExpr should be able to be shared between different threads?)
        // This way the compilation only has to happen once even if someone needs multiple objects for different threads.
        // (Every thread can make a copy from the previously prepared "master" XPath object.)
        assert(namespaces.count == 0, "XPath.evaluateOn: Namespace mappings not yet implemented")

        let context: XPathContext
        do { context = try XPathContext() } catch let e { ptr = nil; throw e }      // If only we could throw errors without initializing all properties first…
        ptr = xmlXPathCtxtCompile(context.ptr, expression)
        guard ptr != nil else {
            throw context.grabAndResetError() ?? XPathError(xmlError: nil)
        }
    }

    deinit {
        xmlXPathFreeCompExpr(ptr);
    }

    public func evaluateOn(node: Node) throws -> XPathResult {
        let context = try XPathContext(node: node)
        let obj = xmlXPathCompiledEval(ptr, context.ptr)
        guard obj != nil else {
            throw context.grabAndResetError() ?? XPathError(xmlError: nil)
        }
        return XPathResult(ptr: obj, onNode: node)
    }

    public func evaluateOn(doc: Document) throws -> XPathResult {
        return try evaluateOn(doc.root)
    }
}

private func NodesFromNodeSet(ns: xmlNodeSetPtr, doc: libxmlDoc) -> [Node]
{
    precondition(ns != nil)
    let na = ns.memory.nodeTab
    precondition((na == nil) == (ns.memory.nodeNr == 0))  // read outer "==" as "if and only if"
    let xmlNodes = na.stride(to: na.advancedBy(Int(ns.memory.nodeNr)), by: 1)
    return xmlNodes.map {
        return Node($0.memory, doc: doc)
    }
}

// For users only the four basic types should be relevant: Node set, boolean, number, string.
public enum XPathValue {
    case NodeSet([Node])
    case BoolValue(Bool)
    case NumberValue(Double)
    case StringValue(String)

    case _Undefined
    case _Point
    case _Range
    case _LocationSet
    case _UserData
    case _XSLTTree

    /// Initialize the appropriate XPathValue for the given xmlXPathObject.
    /// Does not free the xmlXPathObject.
    private init(ptr: xmlXPathObjectPtr, onNode node: Node) {
        precondition(ptr != nil)

        switch ptr.memory.type.rawValue {
        case XPATH_NODESET.rawValue:
            self = .NodeSet(NodesFromNodeSet(ptr.memory.nodesetval, doc: node.doc))
        case XPATH_BOOLEAN.rawValue:
            self = .BoolValue(ptr.memory.boolval != 0)
        case XPATH_NUMBER.rawValue:
            self = .NumberValue(ptr.memory.floatval)
        case XPATH_STRING.rawValue:
            precondition(ptr.memory.stringval != nil) // TODO: Can/should we really assume that?
            self = .StringValue(String.fromXMLString(ptr.memory.stringval)!)

        case XPATH_UNDEFINED.rawValue:
            debugPrint("Unexpected xmlXPathObjectType: XPATH_UNDEFINED")
            self = ._Undefined
        case XPATH_POINT.rawValue:
            // Denotes a point, index ptr.memory.index in node xmlNodePtr(ptr.memory.user) according to code in xmlXPathDebugDumpObject
            debugPrint("Unexpected xmlXPathObjectType: XPATH_POINT")
            self = ._Point
        case XPATH_RANGE.rawValue:
            // Object is a range(?), see implementation of xmlXPathDebugDumpObject
            debugPrint("Unexpected xmlXPathObjectType: XPATH_RANGE")
            self = ._Range
        case XPATH_LOCATIONSET.rawValue:
            // Object is a location set(?) at xmlLocationSetPtr(ptr.memory.user)
            debugPrint("Unexpected xmlXPathObjectType: XPATH_LOCATIONSET")
            self = ._LocationSet
        case XPATH_USERS.rawValue:
            // User data, stored in ptr.memory.user (see xmlXPathWrapExternal)
            debugPrint("Unexpected xmlXPathObjectType: XPATH_USERS")
            self = ._UserData
        case XPATH_XSLT_TREE.rawValue:
            // Seems to use ptr.memory.nodesetval to store some nodes
            debugPrint("Unexpected xmlXPathObjectType: XPATH_XSLT_TREE")
            self = ._XSLTTree
        default:
            fatalError("Unknown xmlXPathObjectType: \(ptr.memory.type.rawValue)")
        }

    }
}

public class XPathResult {
    private let ptr: xmlXPathObjectPtr
    private let node: Node
    public private(set) lazy var value: XPathValue = XPathValue(ptr: self.ptr, onNode: self.node)

    /// Wraps the given pointer and assumes ownership of the memory.
    private init(ptr: xmlXPathObjectPtr, onNode node: Node) {
        precondition(ptr != nil)
        self.ptr = ptr
        self.node = node
    }

    public func asBool() -> Bool {
        return xmlXPathCastToBoolean(ptr) != 0
    }

    public func asNumber() -> Double {
        return xmlXPathCastToNumber(ptr)
    }

    public func asString() -> String {
        if ptr.memory.type == XPATH_STRING {
            switch value {
            case .StringValue(let s): return s
            default: assertionFailure("XPATH_STRING cannot have a value type other than XPathValue.StringValue")
            }
        }
        let cs = xmlXPathCastToString(ptr)
        defer { xmlFree(cs) }
        // xmlXPathCastToString only returns NULL if xmlStrdup fails, which is most likely due to a memory allocation error.
        precondition(cs != nil, "xmlXPathCastToString returned NULL") // better crash instead of silently returning wrong data
        return String.fromXMLString(cs)!
    }

    public func asNodeSet() -> [Node]? {
        switch value {
        case .NodeSet(let nodes): return nodes
        default: return nil
        }
    }

    deinit {
        xmlXPathFreeObject(ptr);
    }
}
