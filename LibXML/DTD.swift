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
    private let keepAlive: libxmlDoc

    init(_ xmlDtd: xmlDtdPtr, keepAlive: libxmlDoc) {
        self.ptr = xmlDtd
        self.keepAlive = keepAlive
        assert(self.ptr != nil && self.ptr.memory.type == XML_DTD_NODE)
    }

    public var entities: [Entity] {
        return CLinkedList(self.ptr.memory.children)
            .filter { $0.memory.type == XML_ENTITY_DECL }
            .map { Entity(xmlEntityPtr($0), keepAlive: self.keepAlive) }
    }
}

public class Entity {
    private let ptr: xmlEntityPtr
    private let keepAlive: libxmlDoc

    init(_ xmlEntity: xmlEntityPtr, keepAlive: libxmlDoc) {
        self.ptr = xmlEntity
        self.keepAlive = keepAlive
        assert(self.ptr != nil && self.ptr.memory.type == XML_ENTITY_DECL)
    }

    public var name: String? {
        return String.fromCString(self.ptr.memory.name)
    }

    public var orig: String? {
        return String.fromCString(self.ptr.memory.orig)
    }

    public var content: String? {
        return String.fromCString(self.ptr.memory.content)
    }
}