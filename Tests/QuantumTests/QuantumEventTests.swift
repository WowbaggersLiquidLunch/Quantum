//
//	QuantumTests.swift
//	Quantum
//
//	Created on 2021-01-10.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import XCTest
@testable import Quantum

final class QuantumEventTests: XCTestCase {
	
	func testSingleEvent() {
		func testSingleEvent<State>(_ event: QuantumEvent<State>, state: State) {
			XCTAssertEqual(event.state, state)
			XCTAssertTrue(event.initialObservedEvent === event)
			XCTAssertNil(event.immediatelyPrecedingObservedEvent)
			XCTAssertNil(event.immediatelySucceedingObservedEvent)
			XCTAssertTrue(event.finalObservedEvent === event)
			XCTAssertNil(event.immediatelyPrecedingUnobservedEvent)
			XCTAssertTrue(event.immediatelySucceedingUnobservedEvents.isEmpty)
			XCTAssertTrue(event.isInitialObservedEvent)
			XCTAssertTrue(event.isFinalObservedEvent)
			XCTAssertTrue(event.isObservedEvent)
			XCTAssertFalse(event.isFinalUnobservedEvent)
			XCTAssertFalse(event.isUnobservedEvent)
			XCTAssertTrue(event.isBranchableEvent)
			XCTAssertTrue(event.precedingObservedEvents.isEmpty)
			XCTAssertTrue(event.succeedingObservedEvents.isEmpty)
			XCTAssertTrue(event.precedingUnobservedEvents.isEmpty)
			XCTAssertTrue(event.succeedingUnobservedEvents.isEmpty)
			XCTAssertTrue(event.allUnobservedEvents.isEmpty)
			XCTAssertEqual(event.allBranchableEvents.count, 1)
			XCTAssertTrue(event.allBranchableEvents.first === event)
			XCTAssertEqual(event.equiStatalObservedEvents.count, 1)
			XCTAssertTrue(event.equiStatalObservedEvents.first === event)
			XCTAssertEqual(event.equiStatalBranchableEvents.count, 1)
			XCTAssertTrue(event.equiStatalBranchableEvents.first === event)
			XCTAssertTrue(event.equiStatalUnobservedEvents.isEmpty)
			XCTAssertEqual(event.outcomeProbabilities, [state: 1])
		}
		
		let onlyTextEvent = QuantumEvent(arrivingAt: "abc")
		let onlyNumberEvent = QuantumEvent(arrivingAt: 0)
		
		testSingleEvent(onlyTextEvent, state: "abc")
		testSingleEvent(onlyNumberEvent, state: 0)
		
		onlyTextEvent.observeNextEvent()
		onlyNumberEvent.observeNextEvent()
		
		testSingleEvent(onlyTextEvent, state: "abc")
		testSingleEvent(onlyNumberEvent, state: 0)
	}
	
	func testSingleObservedEventWithUnobservedEvents() {
		func testSingleObservedEvent<State>(_ event: QuantumEvent<State>, state: State) {
			XCTAssertEqual(event.state, state)
			XCTAssertTrue(event.initialObservedEvent === event)
			XCTAssertNil(event.immediatelyPrecedingObservedEvent)
			XCTAssertNil(event.immediatelySucceedingObservedEvent)
			XCTAssertTrue(event.finalObservedEvent === event)
			XCTAssertNil(event.immediatelyPrecedingUnobservedEvent)
			XCTAssertTrue(event.isInitialObservedEvent)
			XCTAssertTrue(event.isFinalObservedEvent)
			XCTAssertTrue(event.isObservedEvent)
			XCTAssertFalse(event.isFinalUnobservedEvent)
			XCTAssertFalse(event.isUnobservedEvent)
			XCTAssertTrue(event.isBranchableEvent)
			XCTAssertTrue(event.precedingObservedEvents.isEmpty)
			XCTAssertTrue(event.succeedingObservedEvents.isEmpty)
			XCTAssertTrue(event.precedingUnobservedEvents.isEmpty)
			XCTAssertEqual(event.equiStatalObservedEvents.count, 1)
			XCTAssertTrue(event.equiStatalObservedEvents.first === event)
		}
		
		let textEvent = QuantumEvent(arrivingAt: "abc")
		
		textEvent.moveSucceedingUnobservedEvents(to: "bcd")	//	Should have no effect.
		testSingleObservedEvent(textEvent, state: "abc")
		XCTAssertTrue(textEvent.immediatelySucceedingUnobservedEvents.isEmpty)
		XCTAssertTrue(textEvent.succeedingUnobservedEvents.isEmpty)
		XCTAssertTrue(textEvent.allUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.allBranchableEvents.count, 1)
		XCTAssertTrue(textEvent.allBranchableEvents.first === textEvent)
		XCTAssertEqual(textEvent.equiStatalBranchableEvents.count, 1)
		XCTAssertTrue(textEvent.equiStatalBranchableEvents.first === textEvent)
		XCTAssertTrue(textEvent.equiStatalUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.outcomeProbabilities, ["abc": 1])
		
		textEvent.moveSucceedingUnobservedEvents(to: "cde", withThisEvent: false)	//	Should have no effect.
		testSingleObservedEvent(textEvent, state: "abc")
		XCTAssertTrue(textEvent.immediatelySucceedingUnobservedEvents.isEmpty)
		XCTAssertTrue(textEvent.succeedingUnobservedEvents.isEmpty)
		XCTAssertTrue(textEvent.allUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.allBranchableEvents.count, 1)
		XCTAssertTrue(textEvent.allBranchableEvents.first === textEvent)
		XCTAssertEqual(textEvent.equiStatalBranchableEvents.count, 1)
		XCTAssertTrue(textEvent.equiStatalBranchableEvents.first === textEvent)
		XCTAssertTrue(textEvent.equiStatalUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.outcomeProbabilities, ["abc": 1])
		
		textEvent.moveSucceedingUnobservedEvents(to: "def", withThisEvent: true)
		testSingleObservedEvent(textEvent, state: "abc")
		XCTAssertFalse(textEvent.immediatelySucceedingUnobservedEvents.isEmpty)
		XCTAssertFalse(textEvent.succeedingUnobservedEvents.isEmpty)
		XCTAssertFalse(textEvent.allUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.allBranchableEvents.count, 2)
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0 === textEvent } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "def" } ))
		XCTAssertEqual(textEvent.equiStatalBranchableEvents.count, 1)
		XCTAssertTrue(textEvent.equiStatalBranchableEvents.first === textEvent)
		XCTAssertTrue(textEvent.equiStatalUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.outcomeProbabilities, ["abc": 0.5, "def": 0.5])
		
		textEvent.move(to: "efg")
		testSingleObservedEvent(textEvent, state: "abc")
		XCTAssertFalse(textEvent.immediatelySucceedingUnobservedEvents.isEmpty)
		XCTAssertFalse(textEvent.succeedingUnobservedEvents.isEmpty)
		XCTAssertFalse(textEvent.allUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.allBranchableEvents.count, 3)
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0 === textEvent } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "def" } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "efg" } ))
		XCTAssertEqual(textEvent.equiStatalBranchableEvents.count, 1)
		XCTAssertTrue(textEvent.equiStatalBranchableEvents.first === textEvent)
		XCTAssertTrue(textEvent.equiStatalUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.outcomeProbabilities, ["abc": 0.25, "def": 0.5, "efg": 0.25])
		
		textEvent.move(to: "fgh", withEquiStatalBranchableEvents: false)
		testSingleObservedEvent(textEvent, state: "abc")
		XCTAssertFalse(textEvent.immediatelySucceedingUnobservedEvents.isEmpty)
		XCTAssertFalse(textEvent.succeedingUnobservedEvents.isEmpty)
		XCTAssertFalse(textEvent.allUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.allBranchableEvents.count, 4)
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0 === textEvent } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "def" } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "efg" } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "fgh" } ))
		XCTAssertEqual(textEvent.equiStatalBranchableEvents.count, 1)
		XCTAssertTrue(textEvent.equiStatalBranchableEvents.first === textEvent)
		XCTAssertTrue(textEvent.equiStatalUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.outcomeProbabilities, ["abc": 0.125, "def": 0.5, "efg": 0.25, "fgh": 0.125])
		
		textEvent.move(to: "ghi", withEquiStatalBranchableEvents: true)
		testSingleObservedEvent(textEvent, state: "abc")
		XCTAssertFalse(textEvent.immediatelySucceedingUnobservedEvents.isEmpty)
		XCTAssertFalse(textEvent.succeedingUnobservedEvents.isEmpty)
		XCTAssertFalse(textEvent.allUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.allBranchableEvents.count, 5)
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0 === textEvent } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "def" } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "efg" } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "fgh" } ))
		XCTAssertTrue(textEvent.allBranchableEvents.contains(where: { $0.state == "ghi" } ))
		XCTAssertEqual(textEvent.equiStatalBranchableEvents.count, 1)
		XCTAssertTrue(textEvent.equiStatalBranchableEvents.first === textEvent)
		XCTAssertTrue(textEvent.equiStatalUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.outcomeProbabilities, ["abc": 0.0625, "def": 0.5, "efg": 0.25, "fgh": 0.125, "ghi": 0.0625])
		
		textEvent.observeNextEvent()
		XCTAssertEqual(textEvent.state, "abc")
		XCTAssertTrue(textEvent.initialObservedEvent === textEvent)
		XCTAssertNil(textEvent.immediatelyPrecedingObservedEvent)
		XCTAssertNotNil(textEvent.immediatelySucceedingObservedEvent)
		XCTAssertFalse(textEvent.finalObservedEvent === textEvent)
		XCTAssertNil(textEvent.immediatelyPrecedingUnobservedEvent)
		XCTAssertTrue(textEvent.immediatelySucceedingUnobservedEvents.isEmpty)
		XCTAssertTrue(textEvent.isInitialObservedEvent)
		XCTAssertFalse(textEvent.isFinalObservedEvent)
		XCTAssertTrue(textEvent.isObservedEvent)
		XCTAssertFalse(textEvent.isFinalUnobservedEvent)
		XCTAssertFalse(textEvent.isUnobservedEvent)
		XCTAssertFalse(textEvent.isBranchableEvent)
		XCTAssertTrue(textEvent.precedingObservedEvents.isEmpty)
		XCTAssertEqual(textEvent.succeedingObservedEvents.count, 1)
		XCTAssertTrue(textEvent.precedingUnobservedEvents.isEmpty)
		XCTAssertTrue(textEvent.succeedingUnobservedEvents.isEmpty)
		XCTAssertTrue(textEvent.allUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.allBranchableEvents.count, 1)
		XCTAssertFalse(textEvent.allBranchableEvents.contains(where: { $0 === textEvent } ))
		XCTAssertEqual(textEvent.equiStatalObservedEvents.count, 1)
		XCTAssertTrue(textEvent.equiStatalObservedEvents.first === textEvent)
		XCTAssertTrue(textEvent.equiStatalBranchableEvents.isEmpty)
		XCTAssertFalse(textEvent.equiStatalBranchableEvents.first === textEvent)
		XCTAssertTrue(textEvent.equiStatalUnobservedEvents.isEmpty)
		XCTAssertNil(textEvent.outcomeProbabilities["abc"])
		
		//	TODO: Test other types for `State`.
	}
	
	//	TODO: Test more kinds of events:
	//	      initial non-final observed events,
	//	      non-initial non-final observed events,
	//	      non-initial final observed events without unobserved events,
	//	      non-initial final observed events with unobserved events,
	//	      non-final unobserved events at depth 1,
	//	      non-final unobserved events at depth > 1,
	//	      final unobserved events.
}
