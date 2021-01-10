import XCTest
@testable import Quantum

final class QuantumTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Quantum().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
