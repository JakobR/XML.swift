import Foundation
import libxml2

public struct ParserOptions: OptionSetType {
    /// Note: This is not the value passed to libxml2!
    public let rawValue: Int32

    /// Note: This is not the value passed to libxml2!
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    public init(libxml2Value: Int32) {
        self.rawValue = libxml2Value
        self.exclusiveOrInPlace(.OptionsWithFlippedSemantics)
        assert(self.libxml2Value == libxml2Value)
    }

    /// The value that is passed to libxml2.
    public var libxml2Value: Int32 {
        return self.exclusiveOr(.OptionsWithFlippedSemantics).rawValue
    }

    init(option: xmlParserOption) {
        self.rawValue = Int32(option.rawValue)
    }

    /// These options have their meaning flipped compared to their libxml2 counterpart.
    private static let OptionsWithFlippedSemantics = ParserOptions([.PrintWarnings, .PrintErrors])

    // TODO: Names
    /// Default value: All options off.
    public static let Default               = ParserOptions(rawValue: 0)
    public static let RecoverOnError        = ParserOptions(option: XML_PARSE_RECOVER)
    public static let ResolveEntities       = ParserOptions(option: XML_PARSE_NOENT)
    public static let LoadExternalDTD       = ParserOptions(option: XML_PARSE_DTDLOAD)
    public static let AttributeDefaults     = ParserOptions(option: XML_PARSE_DTDATTR)
    public static let ValidateDTD           = ParserOptions(option: XML_PARSE_DTDVALID)
    /// Instruct the parser to print errors to standard output.
    public static let PrintErrors           = ParserOptions(option: XML_PARSE_NOERROR)      // semantics flipped
    /// Instruct the parser to print warnings to standard output.
    public static let PrintWarnings         = ParserOptions(option: XML_PARSE_NOWARNING)    // semantics flipped
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

/// Owns an xmlDocPtr and ensures correct clean-up. There must be at most one libxmlDoc instance per xmlDoc structure.
///
/// This is outside the Document class because the xmlDocPtr needs to be kept alive by child Node instances, even if the parent Document is already deallocated.
/// (The libxmlDoc basically functions as an std::shared_ptr<xmlDoc>.)
class libxmlDoc {
    let ptr: xmlDocPtr

    init(context: ParserContext, data: NSData, encoding: UnsafePointer<CChar>, options: ParserOptions) throws {
        print("Using libxml2 of version \(LIBXML_DOTTED_VERSION)")
        print("replace entities? \(context.ptr.memory.replaceEntities)  (should be zero)")
        ptr = xmlCtxtReadMemory(context.ptr, UnsafePointer<CChar>(data.bytes), CInt(data.length), nil, encoding, options.libxml2Value)
        guard ptr != nil else {
            throw Error.ParseError(message: context.lastErrorMessage ?? "")
        }
        guard context.isValid else {
            throw Error.InvalidDocument(message: context.lastErrorMessage ?? "")
        }
    }

    deinit {
        xmlFreeDoc(ptr)
    }

    func getRoot() -> Node {
        let node = xmlDocGetRootElement(ptr)
        return Node(node, doc: self)
    }

    func getInternalDTD() -> DTD {
        return DTD(ptr.memory.intSubset, doc: self)
    }
}

public class Document {
    private let doc: libxmlDoc

    public private(set) lazy var root: Node = self.doc.getRoot()
    public private(set) lazy var internalDTD: DTD = self.doc.getInternalDTD()

    private init(doc: libxmlDoc) {
        self.doc = doc
    }

//    private convenience init(data: NSData, options: ParserOptions, encoding: [CChar]?) throws {
//        // Need intermediate variable to avoid crash
//        let doc = try libxmlDoc(context: ParserContext(), data: data, encoding: encoding, options: options)
//        self.init(doc: doc)
//    }
//
//    public convenience init(data: NSData, options: ParserOptions = .Default, encoding: NSStringEncoding? = nil) throws {
//        try self.init(data: data, options: options, encoding: encoding.map(encodingName))
//    }

    // Use a factory method instead of convenience initializers to avoid crashes (probably a bug in Swift).
    public static func create(data data: NSData, options: ParserOptions = .Default, encoding: NSStringEncoding? = nil) throws -> Document {
        let ctx = try ParserContext()
        let encName = try encoding.map(encodingName)
        let doc = try withOptionalCString(encName) { enc in
            return try libxmlDoc(context: ctx, data: data, encoding: enc, options: options)
        }
        return Document(doc: doc)
    }

}

private func encodingName(encoding: NSStringEncoding) throws -> String {
    if let name = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding)) as String? {
        return name
    } else {
        throw Error.UnknownEncoding
    }
}
