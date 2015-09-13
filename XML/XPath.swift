import libxml2

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

    /// Evaluates the XPath query with the given node as context node.
    public func evaluateOn(node: Node) throws -> XPathResult {
        let context = try XPathContext(node: node)
        let obj = xmlXPathCompiledEval(ptr, context.ptr)
        guard obj != nil else {
            throw context.grabAndResetError() ?? XPathError(xmlError: nil)
        }
        return XPathResult(ptr: obj, onNode: node)
    }

    /// Evaluates the XPath query with the given document's root node as context node.
    public func evaluateOn(doc: Document) throws -> XPathResult {
        return try evaluateOn(doc.root)
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
