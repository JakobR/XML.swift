//
//  XMLDocument.swift
//  LibXML
//
//  Created by Jakob Rath on 29/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2


private func encodingName(encoding: NSStringEncoding) throws -> [CChar] {
    guard let encodingName = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding)) as String? else {
        throw Error.UnknownEncoding
    }
    guard let cString = encodingName.cStringUsingEncoding(NSASCIIStringEncoding) else {
        throw Error.UnknownEncoding
    }
    return cString
}

/// Owns an xmlDocPtr and ensures correct clean-up.
/// This is outside the XMLDocument class because the xmlDocPtr needs to be kept alive by child XMLNode instances, even
/// if the parent XMLDocument is already deallocated.
/// (This is basically used like an std::shared_ptr<xmlDoc>.)
class libxmlDoc {
    let ptr: xmlDocPtr

    init(context: ParserContext, data: NSData, encoding: [CChar], options: Int32) throws {
        print("Using libxml2 of version \(LIBXML_DOTTED_VERSION)")
        print("replace entities? \(context.ptr.memory.replaceEntities)  (should be zero)")
        ptr = xmlCtxtReadMemory(context.ptr, UnsafePointer<Int8>(data.bytes), CInt(data.length), nil, encoding, options)
        guard ptr != nil else {
            throw Error.UnknownError
        }
        guard context.isValid else {
            throw Error.UnknownError
        }

    }

    deinit {
        print("Calling xmlFreeDoc...")
        xmlFreeDoc(ptr)
    }

    func getRoot() -> Node {
        let node = xmlDocGetRootElement(ptr)
        return Node(node, keepAlive: self)
    }

    func getInternalDTD() -> DTD {
        return DTD(ptr.memory.intSubset, keepAlive: self)
    }
}

public class Document {
    private let doc: libxmlDoc

    public lazy var root: Node = self.doc.getRoot()
    public lazy var internalDTD: DTD = self.doc.getInternalDTD()

    private init(doc: libxmlDoc) {
        self.doc = doc
    }

    private convenience init(data: NSData, encoding: [CChar]) throws {
        let options = /*Int32(XML_PARSE_DTDLOAD.rawValue) |*/ Int32(XML_PARSE_DTDVALID.rawValue) | Int32(XML_PARSE_DTDATTR.rawValue) | Int32(XML_PARSE_NONET.rawValue)
        self.init(doc: try libxmlDoc(context: ParserContext(), data: data, encoding: encoding, options: options))
    }

    public convenience init(data: NSData, encoding: NSStringEncoding = NSUTF8StringEncoding) throws {
        try self.init(data: data, encoding: try encodingName(encoding))
    }
}
