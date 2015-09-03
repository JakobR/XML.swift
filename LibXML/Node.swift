//
//  Node.swift
//  LibXML
//
//  Created by Jakob Rath on 30/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2

public class Node {
    private let ptr: xmlNodePtr
    private let keepAlive: libxmlDoc

    init(_ xmlNode: xmlNodePtr, keepAlive: libxmlDoc) {
        self.ptr = xmlNode
        self.keepAlive = keepAlive
    }

    public private(set) lazy var name: String? = String.fromCString(self.ptr.memory.name)

    public private(set) lazy var children: [Node] = CLinkedList(self.ptr.memory.children).map { Node($0, keepAlive: self.keepAlive) }

    public private(set) lazy var attributes: [Attribute] = CLinkedList(self.ptr.memory.properties).map { Attribute($0, keepAlive: self.keepAlive) }

    /// Attribute lookup (not namespace aware)
    public func valueForAttribute(name: String) -> String? {
        let cs = xmlGetProp(ptr, name)
        defer { xmlFree(cs) }
        return String.fromCString(cs)
    }

    /// Namespace-aware attribute lookup
    public func valueForAttribute(name: String, namespace: String) -> String? {
        let cs = xmlGetNsProp(ptr, name, namespace)
        defer { xmlFree(cs) }
        return String.fromCString(cs)
    }
}
