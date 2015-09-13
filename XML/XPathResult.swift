import libxml2

public class XPathResult {
    private let ptr: xmlXPathObjectPtr
    private let node: Node
    public private(set) lazy var value: XPathValue = XPathValue(ptr: self.ptr, onNode: self.node)

    /// Wraps the given pointer and assumes ownership of the memory.
    init(ptr: xmlXPathObjectPtr, onNode node: Node) {
        precondition(ptr != nil)
        self.ptr = ptr
        self.node = node
    }

    public func asBool() -> Bool {
        return xmlXPathCastToBoolean(ptr) != 0
    }

    // TODO: Use "Double" instead of "Number" on the Swift side?
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
        // TODO: Maybe we want an empty list in the "default" case? This would be in line with the other asType() functions.
        switch value {
        case .NodeSet(let nodes): return nodes
        default: return nil
        }
    }
    
    deinit {
        xmlXPathFreeObject(ptr);
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
