import XCTest
import Nimble
@testable import XML

class FrameworkTests: XCTestCase {

    /// Test if the umbrella header is included correctly.
    func testVersionConstants() {
        expect(XML.XMLVersionNumber) > 0
    }

}
