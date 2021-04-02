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
	
	@Quantum
	var quantumText = ""
	
	@Quantum
	var quantumNumber = 0
	
	override func setUp() {
		$quantumText = Quantum(initialState: "abc")
		$quantumNumber = Quantum(initialState: 0)
	}
	
	func testSystemWideSuperposition() {
		
		quantumText = "bcd"
		$quantumText.superpose(on: "cde")
		quantumText = "def"
		
		quantumNumber = 1
		quantumNumber = 2
		$quantumNumber.superpose(on: 1)
		
		XCTAssertEqual(
			$quantumText.outcomeProbabilities,
			[
				"abc": 0.125,
				"bcd": 0.125,
				"cde": 0.25,
				"def": 0.5
			]
		)
		
		let observedString = quantumText
		
		XCTAssertTrue(["abc", "bcd", "cde", "def"].contains(observedString))
		
		XCTAssertEqual(
			$quantumText.outcomeProbabilities,
			[observedString: 1]
		)
		
		XCTAssertEqual(
			$quantumNumber.outcomeProbabilities,
			[
				0: 0.125,
				1: 0.625,
				2: 0.25
			]
		)
		
		let observedInt = quantumNumber
		
		XCTAssertTrue([0, 1, 2].contains(observedInt))
		
		XCTAssertEqual(
			$quantumNumber.outcomeProbabilities,
			[observedInt: 1]
		)
		
		let newQuantumNumber = $quantumNumber.superposed(on: 3)
		
		XCTAssertEqual(
			newQuantumNumber.outcomeProbabilities,
			[
				observedInt: 0.5,
				3: 0.5
			]
		)
		
	}
	
	func testStateSpecificSuperposition() {
		
		$quantumText.superpose("abc", on: "bcd")
		$quantumText.superpose("abc", on: "cde")
		$quantumText.superpose("abc", on: "def")
		$quantumText.superpose("abc", on: "def")
		$quantumText.superpose("efg", on: "abc")	//	Should have no effect
		
		XCTAssertEqual(
			$quantumText.outcomeProbabilities,
			[
				"abc": 0.0625,
				"bcd": 0.5,
				"cde": 0.25,
				"def": 0.1875
			]
		)
		
		$quantumNumber.superpose(1, on: 2)	//	Should have no effect
		$quantumNumber.superpose(0, on: 1)
		$quantumNumber.superpose(1, on: 2)
		$quantumNumber.superpose(0, on: 3)
		$quantumNumber.superpose(3, on: 1)
		
		XCTAssertEqual(
			$quantumNumber.outcomeProbabilities,
			[
				0: 0.25,
				1: 0.375,
				2: 0.25,
				3: 0.125
			]
		)
		
	}
	
}
