import XCTest
@testable import qyz

final class qyzTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(qyz().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
