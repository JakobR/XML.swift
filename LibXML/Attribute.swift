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
    private let keepAlive: libxmlDoc

    init(_ xmlAttr: xmlAttrPtr, keepAlive: libxmlDoc) {
        self.ptr = xmlAttr
        self.keepAlive = keepAlive
        assert(self.ptr != nil && self.ptr.memory.type == XML_ATTRIBUTE_NODE)
    }

    public private(set) lazy var namespace: Namespace = Namespace(self.ptr.memory.ns, keepAlive: self.keepAlive)

    public private(set) lazy var name: String? = String.fromCString(self.ptr.memory.name)

    public private(set) lazy var value: String? = {
        // Mimics the behaviour of the xmlGetProp function
        let children = self.ptr.memory.children
        if (children != nil) {
            if (children.memory.next == nil && (children.memory.type == XML_TEXT_NODE || children.memory.type == XML_CDATA_SECTION_NODE)) {
                // Optimization for common case: only 1 text node
                return String.fromCString(children.memory.content)
            } else {
                let str = xmlNodeListGetString(self.ptr.memory.doc, UnsafePointer<xmlNode>(self.ptr), 1)
                defer { xmlFree(str) }
                return String.fromCString(str)  // TODO: Can I avoid the unnecessary copy?
            }
        } else {
            return "";
        }
    }()
}
