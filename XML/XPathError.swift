import libxml2

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
