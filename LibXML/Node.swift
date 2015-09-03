//
//  Node.swift
//  LibXML
//
//  Created by Jakob Rath on 30/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2

// TODO:
// xmlNode is the general structure which encompasses elements, attributes, text, etc.
// Use a more special Element class for elements (only allow attributes on elements?)
public class Node {
    private let ptr: xmlNodePtr
    private let keepAlive: libxmlDoc

    init(_ xmlNode: xmlNodePtr, keepAlive: libxmlDoc) {
        self.ptr = xmlNode
        self.keepAlive = keepAlive
    }

    public var name: String? {
        return String.fromCString(self.ptr.memory.name)
    }

    public var content: String? {
        let cs = xmlNodeGetContent(self.ptr)
        defer { xmlFree(cs) }
        return String.fromCString(cs)
    }

    public var children: [Node] {
        return CLinkedList(self.ptr.memory.children).map { Node($0, keepAlive: self.keepAlive) }
    }

    public var elements: [Node] {
        return CLinkedList(self.ptr.memory.children)
            .filter { $0.memory.type == XML_ELEMENT_NODE }
            .map { Node($0, keepAlive: self.keepAlive) }
    }

    public var attributes: [Attribute] {
        return CLinkedList(self.ptr.memory.properties).map { Attribute($0, keepAlive: self.keepAlive) }
    }

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
