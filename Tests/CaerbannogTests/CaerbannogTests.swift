import XCTest
@testable import Caerbannog

final class CaerbannogTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Caerbannog().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
