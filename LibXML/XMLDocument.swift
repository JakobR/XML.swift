//
//  XMLDocument.swift
//  LibXML
//
//  Created by Jakob Rath on 29/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2


enum XMLError: ErrorType {
    case UnknownEncoding

    case UnknownError // TODO: REMOVE

    case MemoryError
}


// Owns an xmlParserCtxtPtr and ensures it is cleaned up correctly.
private class XMLParserContext {
    let ptr: xmlParserCtxtPtr
    init() throws {
        ptr = xmlNewParserCtxt()
        guard ptr != nil else {
            throw XMLError.MemoryError
        }
    }
    deinit {
        print("Calling xmlFreeParserCtxt...")
        xmlFreeParserCtxt(ptr)
    }
    var isValid: Bool {
        return ptr.memory.valid != 0;
    }
}

private func encodingName(encoding: NSStringEncoding) throws -> [CChar] {
    guard let encodingName = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding)) as String? else {
        throw XMLError.UnknownEncoding
    }
    guard let cString = encodingName.cStringUsingEncoding(NSASCIIStringEncoding) else {
        throw XMLError.UnknownEncoding
    }
    return cString
}

// Wraps an xmlDocPtr and ensures correct clean-up.
// This is outside the XMLDocument class because the xmlDocPtr needs to be kept alive by child XMLNode instances, even
// if the parent XMLDocument is already deallocated.
// (This is basically used like an std::shared_ptr<xmlDoc>.)
private class xmlDocPtrWrapper {
    let doc: xmlDocPtr
    init(context: XMLParserContext, data: NSData, encoding: [CChar], options: Int32) throws {
        print("Using libxml2 of version \(LIBXML_DOTTED_VERSION)")
        print("replace entities? \(context.ptr.memory.replaceEntities)  (should be zero)")
        doc = xmlCtxtReadMemory(context.ptr, UnsafePointer<Int8>(data.bytes), CInt(data.length), nil, encoding, options)
        guard doc != nil else {
            throw XMLError.UnknownError
        }
        guard context.isValid else {
            throw XMLError.UnknownError
        }

        for var nd = doc.memory.intSubset.memory.children; nd != nil; nd = nd.memory.next {
            if nd.memory.type == XML_ENTITY_DECL {
                let name = String.fromCString(UnsafePointer<CChar>(nd.memory.name)) ?? "???"
                //let orig = String.fromCString(UnsafePointer<CChar>(nd.memory.orig))
                let content = String.fromCString(UnsafePointer<CChar>(nd.memory.content)) ?? "???"
                print("Found entity: \(name) -> \(content)")
            }
        }
    }
    deinit {
        print("Calling xmlFreeDoc...")
        xmlFreeDoc(doc)
    }
    func getRoot() -> XMLNode {
        let node = xmlDocGetRootElement(doc)
        return XMLNode(node, xmlDocument: self)
    }
}

public class XMLDocument {
    private let xmlDocument: xmlDocPtrWrapper
    public lazy var root: XMLNode = self.xmlDocument.getRoot()

    private init(xmlDocument: xmlDocPtrWrapper) {
        self.xmlDocument = xmlDocument
    }

    private convenience init(data: NSData, encoding: [CChar]) throws {
        let options = /*Int32(XML_PARSE_DTDLOAD.rawValue) |*/ Int32(XML_PARSE_DTDVALID.rawValue) | Int32(XML_PARSE_DTDATTR.rawValue) | Int32(XML_PARSE_NONET.rawValue)
        self.init(xmlDocument: try xmlDocPtrWrapper(context: XMLParserContext(), data: data, encoding: encoding, options: options))
    }

    public convenience init(url: NSURL, encoding: NSStringEncoding = NSUTF8StringEncoding) throws {
        if let data = NSData(contentsOfURL: url) {
            try self.init(data: data, encoding: try encodingName(encoding))
        } else {
            throw XMLError.UnknownError
        }
    }
}

public class XMLNode {
    private let xmlNode: xmlNodePtr
    private let xmlDocument: xmlDocPtrWrapper

    private init(_ xmlNode: xmlNodePtr, xmlDocument: xmlDocPtrWrapper) {
        self.xmlNode = xmlNode
        self.xmlDocument = xmlDocument
    }

    public lazy var children: [XMLNode] = {
        var children: [XMLNode] = []
        for var nodePtr = self.xmlNode.memory.children; nodePtr != nil; nodePtr = nodePtr.memory.next {
            if xmlNodeIsText(nodePtr) == 0 {
                let child = XMLNode(nodePtr, xmlDocument: self.xmlDocument)
                children.append(child)
            }
        }
        return children
        }()
}