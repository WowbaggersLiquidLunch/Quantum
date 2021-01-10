//
//	QuantumTests.swift
//	Quantum
//
//	Created on 2021-01-10.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import XCTest
@testable import Quantum

final class QuantumTests: XCTestCase {
	func testQuantumValues() {
		//	FIXME: Use local properties once property wrappers support them.
		struct QuantumProduct {
			@Quantum
			var string: String = "abc"
			@Quantum
			var int: Int = 0
		}
		var quantumProduct = QuantumProduct()
		
		quantumProduct.string = "bcd"
		quantumProduct.string = "cde"
		quantumProduct.string = "def"
		
		quantumProduct.int = 1
		quantumProduct.int = 2
		quantumProduct.int = 1
		
		XCTAssertEqual(
			quantumProduct.$string.quantumState,
			[
				"abc": 0.125,
				"bcd": 0.125,
				"cde": 0.25,
				"def": 0.5
			]
		)
		
		let observedString = quantumProduct.string
		
		XCTAssertTrue(["abc", "bcd", "cde", "def"].contains(observedString))
		
		XCTAssertEqual(
			quantumProduct.$string.quantumState,
			[observedString: 1]
		)
		
		XCTAssertEqual(
			quantumProduct.$int.quantumState,
			[
				0: 0.125,
				1: 0.625,
				2: 0.25
			]
		)
		
		let observedInt = quantumProduct.int
		
		XCTAssertTrue([0, 1, 2].contains(observedInt))
		
		XCTAssertEqual(
			quantumProduct.$int.quantumState,
			[observedInt: 1]
		)
		
		let newQuantumInt = quantumProduct.$int.superposed(on: 3)
		
		XCTAssertEqual(
			newQuantumInt.quantumState,
			[
				observedInt: 0.5,
				3: 0.5
			]
		)
		
    }
	
	//	TODO: Test quantum state of quantum states.
	
}
