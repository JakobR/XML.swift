import libxml2

/// The different node types carried by an XML tree.
///
/// Corresponds to libxml2's xmlElementType.
public enum NodeType: xmlElementType.RawValue {
    case Element                = 1     // XML_ELEMENT_NODE
    case Attribute              = 2     // XML_ATTRIBUTE_NODE
    case Text                   = 3     // XML_TEXT_NODE
    case CDATASection           = 4     // XML_CDATA_SECTION_NODE
    case EntityReference        = 5     // XML_ENTITY_REF_NODE
    case Entity                 = 6     // XML_ENTITY_NODE
    case ProcessingInstruction  = 7     // XML_PI_NODE
    case Comment                = 8     // XML_COMMENT_NODE
    case Document               = 9     // XML_DOCUMENT_NODE
    case DocumentType           = 10    // XML_DOCUMENT_TYPE_NODE
    case DocumentFragment       = 11    // XML_DOCUMENT_FRAG_NODE
    case Notation               = 12    // XML_NOTATION_NODE
    case HTMLDocument           = 13    // XML_HTML_DOCUMENT_NODE
    case DTD                    = 14    // XML_DTD_NODE
    case ElementDeclaration     = 15    // XML_ELEMENT_DECL
    case AttributeDeclaration   = 16    // XML_ATTRIBUTE_DECL
    case EntityDeclaration      = 17    // XML_ENTITY_DECL
    case NamespaceDeclaration   = 18    // XML_NAMESPACE_DECL
    case XIncludeStart          = 19    // XML_XINCLUDE_START
    case XIncludeEnd            = 20    // XML_XINCLUDE_END
    case DOCBDocumentNode       = 21    // XML_DOCB_DOCUMENT_NODE

    init(xmlType: xmlElementType)
    {
        self.init(rawValue: xmlType.rawValue)!
    }
}

/// A thin wrapper around libxml2 xmlNode instances.
/// A single libxml2 xmlNode instance might be wrapped by multiple Node instances at the same time (do not rely on identity of instances of this class!).
public class Node {
    let ptr: xmlNodePtr
    let doc: libxmlDoc

    init(_ ptr: xmlNodePtr, doc: libxmlDoc) {
        precondition(ptr != nil)
        precondition(ptr.memory.doc == doc.ptr)
        self.ptr = ptr
        self.doc = doc
    }

    public var namespace: Namespace? {
        guard ptr.memory.ns != nil else { return nil }
        assert(ptr.memory.ns.memory.next == nil)
        return Namespace(ptr.memory.ns, doc: doc)
    }

    public var type: NodeType { return NodeType(xmlType: ptr.memory.type) }

    public var name: String? { return String.fromXMLString(ptr.memory.name) }

    /// Read the text value of a node (either directly carried by the node if it is a text node, or the concatenated text of the node's children).
    /// Entity references are substituted.
    public var text: String? {
        if (type == .Text || type == .CDATASection) {
            return String.fromXMLString(ptr.memory.content)
        } else {
            let cs = xmlNodeGetContent(ptr)
            defer { xmlFree(cs) }
            return String.fromXMLString(cs)
        }
    }

    /// The content directly carried by the node, if applicable.
    public var content: String? {
        return String.fromXMLString(ptr.memory.content)
    }

    public var children: [Node] {
        return CLinkedList(ptr.memory.children).map { Node($0, doc: doc) }
    }

    public var elements: [Node] {
        return CLinkedList(ptr.memory.children)
            .filter { $0.memory.type == XML_ELEMENT_NODE }
            .map { Node($0, doc: doc) }
    }

    public var attributes: [Attribute] {
        return CLinkedList(ptr.memory.properties).map { Attribute($0, doc: doc) }
    }

    /// Attribute lookup (not namespace aware)
    public func valueForAttribute(name: String) -> String? {
        let cs = xmlGetProp(ptr, name)
        defer { xmlFree(cs) }
        return String.fromXMLString(cs)
    }

    /// Namespace-aware attribute lookup
    public func valueForAttribute(name: String, namespace: String) -> String? {
        let cs = xmlGetNsProp(ptr, name, namespace)
        defer { xmlFree(cs) }
        return String.fromXMLString(cs)
    }
}
