import XCTest
@testable import Quantum

final class QuantumTests: XCTestCase {
	func testBasics() {
		let x = 6
		var y = 9
		
		@Quantum
		var z = x * y
		$z.persistentMutationChain = [.movement(x * y)]
		
		XCTAssertEqual(z, 54)
		
		y = 7
		
		XCTAssertEqual(z, 42)
	}
}
