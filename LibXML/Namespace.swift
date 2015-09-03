//
//  Namespace.swift
//  LibXML
//
//  Created by Jakob Rath on 03/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2

public class Namespace {
    private let ptr: xmlNsPtr
    private let keepAlive: libxmlDoc

    init(_ xmlNs: xmlNsPtr, keepAlive: libxmlDoc) {
        self.ptr = xmlNs
        self.keepAlive = keepAlive
        assert(self.ptr != nil)
    }

    public var href: String? {
        return String.fromCString(self.ptr.memory.href)
    }

    public var prefix: String? {
        return String.fromCString(self.ptr.memory.prefix)
    }
}