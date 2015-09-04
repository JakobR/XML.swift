//
//  ParserContext.swift
//  LibXML
//
//  Created by Jakob Rath on 30/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import libxml2

/// Owns an xmlParserCtxtPtr and ensures it is cleaned up correctly.
class ParserContext {
    let ptr: xmlParserCtxtPtr

    init() throws {
        ptr = xmlNewParserCtxt()
        guard ptr != nil else { throw Error.MemoryError }
    }

    deinit {
        xmlFreeParserCtxt(ptr)
    }

    var isValid: Bool {
        return ptr.memory.valid != 0;
    }

    var lastErrorMessage: String? {
        return String.fromCString(ptr.memory.lastError.message)
    }
}
