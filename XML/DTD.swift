//
//  DTD.swift
//  LibXML
//
//  Created by Jakob Rath on 30/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2

public class DTD {
    private let ptr: xmlDtdPtr
    private let doc: libxmlDoc

    init(_ ptr: xmlDtdPtr, doc: libxmlDoc) {
        precondition(ptr != nil)
        precondition(ptr.memory.type == XML_DTD_NODE)
        precondition(ptr.memory.doc == doc.ptr)
        self.ptr = ptr
        self.doc = doc
    }

    public var entities: [Entity] {
        return CLinkedList(ptr.memory.children)
            .filter { $0.memory.type == XML_ENTITY_DECL }
            .map { Entity(xmlEntityPtr($0), doc: doc) }
    }
}

public class Entity {
    private let ptr: xmlEntityPtr
    private let doc: libxmlDoc

    init(_ ptr: xmlEntityPtr, doc: libxmlDoc) {
        precondition(ptr != nil)
        precondition(ptr.memory.type == XML_ENTITY_DECL)
        precondition(ptr.memory.doc == doc.ptr)
        self.ptr = ptr
        self.doc = doc
    }

    public var name: String? {
        return String.fromXMLString(ptr.memory.name)
    }

    public var orig: String? {
        return String.fromXMLString(ptr.memory.orig)
    }

    public var content: String? {
        return String.fromXMLString(ptr.memory.content)
    }
}
