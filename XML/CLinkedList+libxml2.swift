import libxml2

extension _xmlNode: CLinkedListNext {
    var cLinkedListNext: UnsafeMutablePointer<_xmlNode> { return self.next }
}

extension _xmlAttr: CLinkedListNext {
    var cLinkedListNext: UnsafeMutablePointer<_xmlAttr> { return self.next }
}
