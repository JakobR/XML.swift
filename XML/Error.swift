public enum Error: ErrorType {
    /// A libxml2 allocation returned NULL.
    case MemoryError
    case UnknownEncoding
    case ParseError(message: String)
    case InvalidDocument(message: String)
}
