//
//  XPathTests.swift
//  XPathTests
//
//  Created by Jakob Rath on 04/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import XCTest
import Nimble
@testable import XML
import libxml2

class XPathTests: XCTestCase {

    var data1: NSData { return LoadDataForResource("TestDocument1", withExtension: "xml")! }
    var doc1: Document { return try! Document.create(data: data1) }

    func testSuccessfulCompilation() {
        expect { try XPath("//entry") }.notTo(throwError())
    }

    func testFailedCompilation() {
        expect { try XPath("\\") }.to(throwError(errorType: XPathError.self))
        expect { try XPath("//*[1.1.1]") }.to(throwError(errorType: XPathError.self))
    }

    func testNumberEvaluation() {
        expect { try XPath("1 + 2").evaluateOn(self.doc1).asNumber() } ≈ 3 ± 1e-15

        let result = try! XPath("count(//root/entry[@name='second entry']/value)").evaluateOn(self.doc1)
        expect { result.asNumber() } ≈ 2 ± 1e-15
        switch result.value {
        case .NumberValue(let x): expect(x) ≈ 2 ± 1e-15
        default: fail("expected an XPathValue.NumberValue")
        }
    }

    func testStringEvaluation() {
        expect { try XPath("1 + 2").evaluateOn(self.doc1).asString() } == "3"
        expect { try XPath("//root/entry[1]/@name").evaluateOn(self.doc1).asString() } == "first entry"
        expect { try XPath("//root/entry[2]/@name").evaluateOn(self.doc1).asString() } == "second entry"

        let result = try! XPath("concat('hello: ', //root/entry[@name='second entry']/value[2])").evaluateOn(self.doc1)
        expect { result.asString() } == "hello: anything & something"
        switch result.value {
        case .StringValue(let x): expect(x) == "hello: anything & something"
        default: fail("expected an XPathValue.StringValue")
        }
    }

    func testBoolEvaluation() {
        expect { try XPath("//root/entry[1]/@name").evaluateOn(self.doc1).asBool() } == true
        expect { try XPath("//root/doesnotexist").evaluateOn(self.doc1).asBool() } == false

        let result = try! XPath("count(//root/entry[@name='second entry']/value) = 2").evaluateOn(self.doc1)
        expect { result.asBool() } == true
        switch result.value {
        case .BoolValue(let x): expect(x) == true
        default: fail("expected an XPathValue.BoolValue")
        }
    }

    func testNodeSetEvaluation() {
        let result = try! XPath("//root/entry[@name='second entry']/value").evaluateOn(self.doc1)
        switch result.value {
        case .NodeSet(let nodes):
            expect(nodes.count) == 2
            expect(nodes[0].name) == "value"
            expect(nodes[0].text) == "a & something"
        default: fail("expected an XPathValue.NodeSet")
        }
    }

    func testEmptyNodeSetResult() {
        expect { try XPath("count(//root/doesnotexist) = 0").evaluateOn(self.doc1).asBool() } == true
        switch try! XPath("//root/doesnotexist").evaluateOn(self.doc1).value {
        case .NodeSet(let xs): expect(xs).to(beEmpty())
        default: fail("expected an empty XPathValue.NodeSet")
        }
    }

    func testXPathErrorCodeValues() {
        let values = [
            (XPathErrorCode.Ok,                         XPATH_EXPRESSION_OK),
            (XPathErrorCode.NumberError,                XPATH_NUMBER_ERROR),
            (XPathErrorCode.UnfinishedLiteralError,     XPATH_UNFINISHED_LITERAL_ERROR),
            (XPathErrorCode.StartLiteralError,          XPATH_START_LITERAL_ERROR),
            (XPathErrorCode.VariableReferenceError,     XPATH_VARIABLE_REF_ERROR),
            (XPathErrorCode.UndefinedVariable,          XPATH_UNDEF_VARIABLE_ERROR),
            (XPathErrorCode.InvalidPredicate,           XPATH_INVALID_PREDICATE_ERROR),
            (XPathErrorCode.ExpressionError,            XPATH_EXPR_ERROR),
            (XPathErrorCode.UnclosedBrace,              XPATH_UNCLOSED_ERROR),
            (XPathErrorCode.UnknownFunction,            XPATH_UNKNOWN_FUNC_ERROR),
            (XPathErrorCode.InvalidOperand,             XPATH_INVALID_OPERAND),
            (XPathErrorCode.InvalidType,                XPATH_INVALID_TYPE),
            (XPathErrorCode.InvalidArity,               XPATH_INVALID_ARITY),
            (XPathErrorCode.InvalidContextSize,         XPATH_INVALID_CTXT_SIZE),
            (XPathErrorCode.InvalidContextPosition,     XPATH_INVALID_CTXT_POSITION),
            (XPathErrorCode.MemoryError,                XPATH_MEMORY_ERROR),
            (XPathErrorCode.SyntaxError,                XPTR_SYNTAX_ERROR),
            (XPathErrorCode.ResourceError,              XPTR_RESOURCE_ERROR),
            (XPathErrorCode.SubResourceError,           XPTR_SUB_RESOURCE_ERROR),
            (XPathErrorCode.UndefinedNamespacePrefix,   XPATH_UNDEF_PREFIX_ERROR),
            (XPathErrorCode.EncodingError,              XPATH_ENCODING_ERROR),
            (XPathErrorCode.InvalidCharacter,           XPATH_INVALID_CHAR_ERROR),
            (XPathErrorCode.InvalidContext,             XPATH_INVALID_CTXT),
            (XPathErrorCode.StackUsageError,            XPATH_STACK_ERROR),
            (XPathErrorCode.ForbiddenVariable,          XPATH_FORBID_VARIABLE_ERROR),
        ]
        print(xmlXPathError.init(rawValue: 250))
        for (x, y) in values {
            expect(x.rawValue).to(equal(Int(y.rawValue)), description: "expected \(x) to have the value of \(y)")
        }
    }

}
