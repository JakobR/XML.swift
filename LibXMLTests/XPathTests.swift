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

    func testCompilation() {
        //        let doc = try! XML.Document.create(data: data1)
        expect { try XPath("//entry") }.notTo(throwError())

        expect { try XPath("\\") }.to(throwError(errorType: XPathError.self))
        expect { try XPath("//*[1.1.1]") }.to(throwError(errorType: XPathError.self))
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
