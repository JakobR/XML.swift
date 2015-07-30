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
    private let keepAlive: Any

    init(_ xmlNode: xmlNodePtr, keepAlive: Any) {
        self.ptr = xmlNode
        self.keepAlive = keepAlive
    }

    public lazy var children: [Node] = CLinkedList(self.ptr.memory.children).map { Node($0, keepAlive: self.keepAlive) }
    /*
    {
        var children: [Node] = []
        for var nodePtr = self.ptr.memory.children; nodePtr != nil; nodePtr = nodePtr.memory.next {
            if xmlNodeIsText(nodePtr) == 0 {
                let child = Node(nodePtr, keepAlive: self.keepAlive)
                children.append(child)
            }
        }
        return children
    }()
    */
}