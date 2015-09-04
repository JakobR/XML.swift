//
//  NodeTypeTests.swift
//  LibXML
//
//  Created by Jakob Rath on 03/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import XCTest
import Nimble
@testable import XML
import libxml2

class NodeTypeTests: XCTestCase {

    /// Make sure the NodeType values do not diverge from the ones defined in libxml2.
    func testValues() {
        let values = [
            (NodeType.Element,                  XML_ELEMENT_NODE),
            (NodeType.Attribute,                XML_ATTRIBUTE_NODE),
            (NodeType.Text,                     XML_TEXT_NODE),
            (NodeType.CDATASection,             XML_CDATA_SECTION_NODE),
            (NodeType.EntityReference,          XML_ENTITY_REF_NODE),
            (NodeType.Entity,                   XML_ENTITY_NODE),
            (NodeType.ProcessingInstruction,    XML_PI_NODE),
            (NodeType.Comment,                  XML_COMMENT_NODE),
            (NodeType.Document,                 XML_DOCUMENT_NODE),
            (NodeType.DocumentType,             XML_DOCUMENT_TYPE_NODE),
            (NodeType.DocumentFragment,         XML_DOCUMENT_FRAG_NODE),
            (NodeType.Notation,                 XML_NOTATION_NODE),
            (NodeType.HTMLDocument,             XML_HTML_DOCUMENT_NODE),
            (NodeType.DTD,                      XML_DTD_NODE),
            (NodeType.ElementDeclaration,       XML_ELEMENT_DECL),
            (NodeType.AttributeDeclaration,     XML_ATTRIBUTE_DECL),
            (NodeType.EntityDeclaration,        XML_ENTITY_DECL),
            (NodeType.NamespaceDeclaration,     XML_NAMESPACE_DECL),
            (NodeType.XIncludeStart,            XML_XINCLUDE_START),
            (NodeType.XIncludeEnd,              XML_XINCLUDE_END),
            (NodeType.DOCBDocumentNode,         XML_DOCB_DOCUMENT_NODE),
        ]
        for (x, y) in values {
            expect(x.rawValue).to(equal(y.rawValue), description: "expected \(x) to have the value of \(y)")
        }
    }

}
