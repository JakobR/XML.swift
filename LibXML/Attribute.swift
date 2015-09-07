//
//  Attribute.swift
//  LibXML
//
//  Created by Jakob Rath on 03/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2

public class Attribute {
    private let ptr: xmlAttrPtr
    private let doc: libxmlDoc

    init(_ ptr: xmlAttrPtr, doc: libxmlDoc) {
        precondition(ptr != nil)
        precondition(ptr.memory.type == XML_ATTRIBUTE_NODE)
        precondition(ptr.memory.doc == doc.ptr)
        self.ptr = ptr
        self.doc = doc
    }

    public var namespace: Namespace? {
        guard ptr.memory.ns != nil else { return nil }
        assert(ptr.memory.ns.memory.next == nil)
        return Namespace(ptr.memory.ns, doc: doc)
    }

    public var name: String? {
        return String.fromXMLString(ptr.memory.name)
    }

    public var value: String? {
        // Mimics the behaviour of the xmlGetProp function
        let children = ptr.memory.children
        if (children != nil) {
            if (children.memory.next == nil && (children.memory.type == XML_TEXT_NODE || children.memory.type == XML_CDATA_SECTION_NODE)) {
                // Optimization for common case: only 1 text node
                return String.fromXMLString(children.memory.content)
            } else {
                let str = xmlNodeListGetString(ptr.memory.doc, xmlNodePtr(ptr), 1)
                defer { xmlFree(str) }
                return String.fromXMLString(str)  // TODO: Can I avoid the unnecessary copy?
            }
        } else {
            return "";
        }
    }
}
