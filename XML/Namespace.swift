import libxml2

public class Namespace {
    private let ptr: xmlNsPtr
    private let doc: libxmlDoc

    init(_ ptr: xmlNsPtr, doc: libxmlDoc) {
        precondition(ptr != nil)
        self.ptr = ptr
        self.doc = doc
    }

    public var href: String? {
        return String.fromXMLString(ptr.memory.href)
    }

    public var prefix: String? {
        return String.fromXMLString(ptr.memory.prefix)
    }
}
