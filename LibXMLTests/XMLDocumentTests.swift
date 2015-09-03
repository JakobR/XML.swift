//
//  XMLDocumentTests.swift
//  XMLDocumentTests
//
//  Created by Jakob Rath on 29/07/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import XCTest
import Nimble
@testable import XML

class XMLDocumentTests: XCTestCase {

    var data1: NSData { return LoadDataForResource("TestDocument1", withExtension: "xml")! }
    var invalidData1: NSData { return LoadDataForResource("InvalidDocument1", withExtension: "xml")! }

    func testDocumentLoading() {
        expect { try XML.Document.create(data: self.data1, options: .Default, encoding: nil) }.notTo(throwError())
    }

    func testDocumentValidation() {
        expect { try XML.Document.create(data: self.data1, options: .ValidateDTD, encoding: nil) }.notTo(throwError())
        expect { try XML.Document.create(data: self.invalidData1, options: .ValidateDTD, encoding: nil) }.to(throwError(XML.Error.InvalidDocument))
    }

    func testEntityResolution() {
        let resolved = try! XML.Document.create(data: data1, options: .ResolveEntities, encoding: nil)
        let unresolved = try! XML.Document.create(data: data1, options: .Default, encoding: nil)

//        for node in unresolved.root.elements {
//            print(node.name.debugDescription + ": " + node.content.debugDescription)
//            for node in node.elements {
//                print("\t" + node.name.debugDescription + ": " + node.content.debugDescription)
//                for node in node.elements {
//                    print("\t\t" + node.name.debugDescription + ": " + node.content.debugDescription)
//                }
//            }
//        }

        expect { resolved.root.children[3].children[1].text }.to(equal("a & something"))
        expect { resolved.root.children[3].children[1].children.count }.to(equal(1))
        expect { unresolved.root.children[3].children[1].text }.to(equal("a & something"), description: "Node.content method always substitutes entities")
        expect { unresolved.root.children[3].children[1].children.count }.to(equal(2))
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
