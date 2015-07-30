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
    private let keepAlive: Any

    init(_ ptr: xmlDtdPtr, keepAlive: Any) {
        self.ptr = ptr
        self.keepAlive = keepAlive
    }

    public lazy var entities: [Entity] = CLinkedList(self.ptr.memory.children)
        .filter { $0.memory.type == XML_ENTITY_DECL }
        .map { Entity(xmlEntityPtr($0), keepAlive: self.keepAlive) }
}

public class Entity {
    private let ptr: xmlEntityPtr
    private let keepAlive: Any

    init(_ ptr: xmlEntityPtr, keepAlive: Any) {
        self.ptr = ptr
        self.keepAlive = keepAlive
    }

    public lazy var name: String? = String.fromCString(UnsafePointer<CChar>(self.ptr.memory.name))
    public lazy var orig: String? = String.fromCString(UnsafePointer<CChar>(self.ptr.memory.orig))
    public lazy var content: String? = String.fromCString(UnsafePointer<CChar>(self.ptr.memory.content))
}