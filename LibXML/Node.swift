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
        assert(self.ptr != nil)
    }

    static func create(ptr: xmlNodePtr, keepAlive: libxmlDoc) -> Node {
        assert(ptr != nil)
        switch (ptr.memory.type.rawValue) {
        case XML_ELEMENT_NODE.rawValue: return Element(ptr, keepAlive: keepAlive)
        default: return Node(ptr, keepAlive: keepAlive)
        }
    }

    public var name: String? {
        return String.fromXMLString(self.ptr.memory.name)
    }

    /// Read the text value of a node (either directly carried by the node if it is a text node, or the concatenated text of the node's children).
    /// Entity references are substituted.
    public var text: String? {
        let cs = xmlNodeGetContent(self.ptr)
        defer { xmlFree(cs) }
        return String.fromXMLString(cs)
    }

    public var children: [Node] {
        return CLinkedList(self.ptr.memory.children).map { Node.create($0, keepAlive: self.keepAlive) }
    }

    public var elements: [Element] {
        return CLinkedList(self.ptr.memory.children)
            .filter { $0.memory.type == XML_ELEMENT_NODE }
            .map { Element($0, keepAlive: self.keepAlive) }
    }
}

public class Element: Node {
    override init(_ xmlNode: xmlNodePtr, keepAlive: libxmlDoc) {
        super.init(xmlNode, keepAlive: keepAlive)
        assert(self.ptr.memory.type == XML_ELEMENT_NODE)
    }

    public var attributes: [Attribute] {
        return CLinkedList(self.ptr.memory.properties).map { Attribute($0, keepAlive: self.keepAlive) }
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
