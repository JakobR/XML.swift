import XCTest
import Nimble
@testable import XML

class DocumentTests: XCTestCase {

    var data1: NSData { return LoadDataForResource("TestDocument1", withExtension: "xml")! }
    var illegalXMLData1: NSData { return LoadDataForResource("IllegalXMLDocument1", withExtension: "xml")! }
    var invalidData1: NSData { return LoadDataForResource("InvalidDocument1", withExtension: "xml")! }

    func testDocumentParsing() {
        expect { try Document.create(data: self.data1) }.notTo(throwError())
        expect { try Document.create(data: self.data1, encoding: NSUTF8StringEncoding) }.notTo(throwError())
        expect { try Document.create(data: self.data1, encoding: 1234567) }.to(throwError(Error.UnknownEncoding))
        expect { try Document.create(data: self.illegalXMLData1) }.to(throwError { (error: XML.Error) in
            switch error {
            case Error.ParseError(let message): expect(message).toNot(beEmpty(), description: "expected a non-empty error message")
            default: fail("expected a ParseError")
            }
        }, description: "expected a ParseError with a non-empty error message")
    }

    func testDocumentValidation() {
        expect { try Document.create(data: self.data1, options: .ValidateDTD) }.notTo(throwError())
        expect { try Document.create(data: self.invalidData1, options: .ValidateDTD) }.to(throwError { (error: XML.Error) in
            switch error {
            case Error.InvalidDocument(let message): expect(message).toNot(beEmpty(), description: "expected a non-empty error message")
            default: fail("expected an InvalidDocument error")
            }
        }, description: "expected an InvalidDocument error with a non-empty error message")
    }

    func testEntityResolution() {
        let resolved = try! Document.create(data: data1, options: .ResolveEntities)
        let unresolved = try! Document.create(data: data1)

        expect { resolved.root.children[3].children[1].text } == "a & something"
        expect { resolved.root.children[3].children[1].children.count } == 1
        expect { resolved.root.children[3].children[3].text } == "anything & something"
        expect { unresolved.root.children[3].children[1].text }.to(equal("a & something"), description: "expected Node.content method to always substitute entities")
        expect { unresolved.root.children[3].children[1].children.count } == 2
    }

    func testEntityList() {
        let doc = try! Document.create(data: data1)
        let entities = doc.internalDTD.entities
        expect { entities.count } == 2
        expect { entities[0].name } == "smth"
        expect { entities[0].content } == "something"
        expect { entities[0].orig } == "something"
        expect { entities[1].name } == "blah"
        expect { entities[1].content } == "anything &amp; &smth;"
        expect { entities[1].orig } == "anything &amp; &smth;"
    }

    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measureBlock {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
