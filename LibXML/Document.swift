//
//  XMLDocument.swift
//  LibXML
//
//  Created by Jakob Rath on 29/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import Foundation
import libxml2

public struct ParserOptions: OptionSetType {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    init(option: xmlParserOption) {
        self.rawValue = Int32(option.rawValue)
    }

    // TODO: Names
    public static let Default               = ParserOptions(rawValue: 0)
    public static let RecoverOnError        = ParserOptions(option: XML_PARSE_RECOVER)
    public static let ResolveEntities       = ParserOptions(option: XML_PARSE_NOENT)
    public static let LoadExternalDTD       = ParserOptions(option: XML_PARSE_DTDLOAD)
    public static let AttributeDefaults     = ParserOptions(option: XML_PARSE_DTDATTR)
    public static let ValidateDTD           = ParserOptions(option: XML_PARSE_DTDVALID)
    public static let SuppressErrors        = ParserOptions(option: XML_PARSE_NOERROR)
    public static let SuppressWarnings      = ParserOptions(option: XML_PARSE_NOWARNING)
    public static let Pedantic              = ParserOptions(option: XML_PARSE_PEDANTIC)
    public static let RemoveBlankNodes      = ParserOptions(option: XML_PARSE_NOBLANKS)
    public static let XINCLUDE              = ParserOptions(option: XML_PARSE_XINCLUDE)
    public static let NoNetworkAccess       = ParserOptions(option: XML_PARSE_NONET)
    public static let NODICT                = ParserOptions(option: XML_PARSE_NODICT)
    public static let NSCLEAN               = ParserOptions(option: XML_PARSE_NSCLEAN)
    public static let NOCDATA               = ParserOptions(option: XML_PARSE_NOCDATA)
    public static let NOXINCNODE            = ParserOptions(option: XML_PARSE_NOXINCNODE)
    public static let COMPACT               = ParserOptions(option: XML_PARSE_COMPACT)
    public static let NOBASEFIX             = ParserOptions(option: XML_PARSE_NOBASEFIX)
    public static let HUGE                  = ParserOptions(option: XML_PARSE_HUGE)
    public static let IgnoreEncodingHint    = ParserOptions(option: XML_PARSE_IGNORE_ENC)
    public static let BIG_LINES             = ParserOptions(option: XML_PARSE_BIG_LINES)

}

private func encodingName(encoding: NSStringEncoding) throws -> [CChar] {
    guard let encodingName = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding)) as String? else { throw Error.UnknownEncoding }
    guard let cString = encodingName.cStringUsingEncoding(NSASCIIStringEncoding) else { throw Error.UnknownEncoding }
    return cString
}

/// Owns an xmlDocPtr and ensures correct clean-up.
/// This is outside the XMLDocument class because the xmlDocPtr needs to be kept alive by child XMLNode instances, even
/// if the parent XMLDocument is already deallocated.
/// (This is basically used like an std::shared_ptr<xmlDoc>.)
class libxmlDoc {
    let ptr: xmlDocPtr

    init(context: ParserContext, data: NSData, encoding: UnsafePointer<Int8>?, options: ParserOptions) throws {
        print("Using libxml2 of version \(LIBXML_DOTTED_VERSION)")
        print("replace entities? \(context.ptr.memory.replaceEntities)  (should be zero)")
        ptr = xmlCtxtReadMemory(context.ptr, UnsafePointer<Int8>(data.bytes), CInt(data.length), nil, encoding ?? UnsafePointer<Int8>(), options.rawValue)
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

    private convenience init(data: NSData, options: ParserOptions, encoding: [CChar]?) throws {
        self.init(doc: try libxmlDoc(context: ParserContext(), data: data, encoding: encoding, options: options))
    }

    public convenience init(data: NSData, options: ParserOptions = .Default, encoding: NSStringEncoding? = nil) throws {
        try self.init(data: data, options: options, encoding: encoding.map(encodingName))
    }
}
