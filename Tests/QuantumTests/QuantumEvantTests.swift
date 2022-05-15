//
//	QuantumEventTests.swift
//	Quantum
//
//	Created on 2022-02-23.
//	Copyleft © 2022 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import XCTest
@testable import Quantum

final class QuantumEventTests: XCTestCase {
	
	func testInitialization() {
		let quantumEvent1 = QuantumEvent(movedTo: 42)
		let quantumEvent2 = QuantumEvent.state(42)
//		XCTAssertEqual(quantumEvent1.entangledEvents, quantumEvent2.entangledEvents)
//		XCTAssertEqual(quantumEvent1.entangledEvents, [])
		XCTAssertTrue( {
			switch (quantumEvent1.mutation, quantumEvent2.mutation) {
			case (.destination(42), .destination(42)): return true
			default: return false
			}
		}() )
		
		let x = 6
		var y = 9
		let quantumEvent3 = QuantumEvent(movement: x * y)
		let quantumEvent4 = QuantumEvent.movement(x * y)
//		XCTAssertEqual(quantumEvent3.entangledEvents, quantumEvent4.entangledEvents)
//		XCTAssertEqual(quantumEvent3.entangledEvents, [])
		y = 7
		XCTAssertTrue( {
			switch (quantumEvent3.mutation, quantumEvent4.mutation) {
			case let (.path(movement3), .path(movement4)):
				return movement3() == 42 && movement4() == 42
			default: return false
			}
		}() )
	}
	
	
}
