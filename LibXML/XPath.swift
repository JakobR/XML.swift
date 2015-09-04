//
//  XPath.swift
//  LibXML
//
//  Created by Jakob Rath on 04/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
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
        return XPathResult(ptr: obj)
    }
}

public class XPathResult {
    private let ptr: xmlXPathObjectPtr

    /// Wraps the given pointer and assumes ownership of the memory.
    init(ptr: xmlXPathObjectPtr) {
        self.ptr = ptr
        assert(self.ptr != nil)
    }

    deinit {
        xmlXPathFreeObject(ptr);
    }
}
