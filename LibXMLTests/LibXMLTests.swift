//
//  LibXMLTests.swift
//  LibXMLTests
//
//  Created by Jakob Rath on 09/09/15.
//  Copyright © 2015 Jakob Rath. All rights reserved.
//

import XCTest
import Nimble
@testable import XML

class LibXMLTests: XCTestCase {

    /// Test if the umbrella header is included correctly.
    func testVersionConstants() {
        expect(XML.XMLVersionNumber) > 0
    }

}
