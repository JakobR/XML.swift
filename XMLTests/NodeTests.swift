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

class NodeTests: XCTestCase {

    var data1: NSData { return LoadDataForResource("TestDocument1", withExtension: "xml")! }
    var doc1: Document { return try! Document.create(data: data1) }

    func testProperties() {
        // <entry> element
        expect { self.doc1.root.children[1].type } == NodeType.Element
        expect { self.doc1.root.children[1].name } == "entry"
        expect { self.doc1.root.children[1].text } == "\n        a value\n        another value\n    "
        expect { self.doc1.root.children[1].content }.to(beNil())
        // <value> element
        expect { self.doc1.root.children[1].children[1].type } == NodeType.Element
        expect { self.doc1.root.children[1].children[1].name } == "value"
        expect { self.doc1.root.children[1].children[1].text } == "a value"
        expect { self.doc1.root.children[1].children[1].content }.to(beNil())
        // text node in <value>
        expect { self.doc1.root.children[1].children[1].children[0].type } == NodeType.Text
        expect { self.doc1.root.children[1].children[1].children[0].name } == "text"
        expect { self.doc1.root.children[1].children[1].children[0].text } == "a value"
        expect { self.doc1.root.children[1].children[1].children[0].content } == "a value"
        // entity reference &smth; in <value>
        expect { self.doc1.root.children[3].children[1].children[1].type } == NodeType.EntityReference
        expect { self.doc1.root.children[3].children[1].children[1].name } == "smth"
        expect { self.doc1.root.children[3].children[1].children[1].text } == "something"
        expect { self.doc1.root.children[3].children[1].children[1].content } == "something"
    }

    /// Make sure the NodeType values do not diverge from the ones defined in libxml2.
    func testNodeTypeValues() {
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
