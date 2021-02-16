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
			XCTAssertNil(event.immediatelyPrecedingEvent)
			XCTAssertTrue(event.earliestObservedEvent === event)
			XCTAssertNil(event.immediatelyPrecedingObservedEvent)
			XCTAssertNil(event.immediatelySucceedingObservedEvent)
			XCTAssertTrue(event.latestObservedEvent === event)
			XCTAssertNil(event.immediatelyPrecedingUnobservedEvent)
			XCTAssertTrue(event.immediatelySucceedingUnobservedEvents.isEmpty)
			XCTAssertTrue(event.isObserved)
			XCTAssertTrue(event.isEarliestObserved)
			XCTAssertTrue(event.isLatestObserved)
			XCTAssertFalse(event.isFinalUnobservedEvent)
			XCTAssertTrue(event.isBranchable)
			XCTAssertTrue(event.precedingObservedEvents.isEmpty)
			XCTAssertTrue(event.succeedingObservedEvents.isEmpty)
			XCTAssertTrue(event.precedingUnobservedEvents.isEmpty)
			XCTAssertTrue(event.succeedingUnobservedEvents.isEmpty)
			XCTAssertTrue(event.allObservedEvents.count == 1)
			XCTAssertTrue(event.allObservedEvents.first === event)
			XCTAssertTrue(event.allUnobservedEvents.isEmpty)
			XCTAssertEqual(event.allBranchableEvents.count, 1)
			XCTAssertTrue(event.allBranchableEvents.first === event)
			XCTAssertEqual(event.equiStatalObservedEvents.count, 1)
			XCTAssertTrue(event.equiStatalObservedEvents.first === event)
			XCTAssertTrue(event.equiStatalSucceedingObservedEvents.isEmpty)
			XCTAssertEqual(event.equiStatalBranchableEvents.count, 1)
			XCTAssertTrue(event.equiStatalBranchableEvents.first === event)
			XCTAssertTrue(event.equiStatalUnobservedEvents.isEmpty)
			XCTAssertTrue(event.equiStatalSucceedingUnobservedEvents.isEmpty)
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
			XCTAssertNil(event.immediatelyPrecedingEvent)
			XCTAssertTrue(event.earliestObservedEvent === event)
			XCTAssertNil(event.immediatelyPrecedingObservedEvent)
			XCTAssertNil(event.immediatelySucceedingObservedEvent)
			XCTAssertTrue(event.latestObservedEvent === event)
			XCTAssertNil(event.immediatelyPrecedingUnobservedEvent)
			XCTAssertTrue(event.isObserved)
			XCTAssertTrue(event.isEarliestObserved)
			XCTAssertTrue(event.isLatestObserved)
			XCTAssertFalse(event.isFinalUnobservedEvent)
			XCTAssertTrue(event.isBranchable)
			XCTAssertTrue(event.precedingObservedEvents.isEmpty)
			XCTAssertTrue(event.succeedingObservedEvents.isEmpty)
			XCTAssertTrue(event.precedingUnobservedEvents.isEmpty)
			XCTAssertEqual(event.allObservedEvents.count, 1)
			XCTAssertTrue(event.allObservedEvents.first === event)
			XCTAssertEqual(event.equiStatalObservedEvents.count, 1)
			XCTAssertTrue(event.equiStatalObservedEvents.first === event)
			XCTAssertTrue(event.equiStatalSucceedingObservedEvents.isEmpty)
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
		XCTAssertTrue(textEvent.equiStatalSucceedingUnobservedEvents.isEmpty)
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
		XCTAssertTrue(textEvent.equiStatalSucceedingUnobservedEvents.isEmpty)
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
		XCTAssertTrue(textEvent.equiStatalSucceedingUnobservedEvents.isEmpty)
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
		XCTAssertTrue(textEvent.equiStatalSucceedingUnobservedEvents.isEmpty)
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
		XCTAssertTrue(textEvent.equiStatalSucceedingUnobservedEvents.isEmpty)
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
		XCTAssertTrue(textEvent.equiStatalSucceedingUnobservedEvents.isEmpty)
		XCTAssertEqual(textEvent.outcomeProbabilities, ["abc": 0.0625, "def": 0.5, "efg": 0.25, "fgh": 0.125, "ghi": 0.0625])
		
		textEvent.observeNextEvent()
		XCTAssertEqual(textEvent.state, "abc")
		XCTAssertTrue(textEvent.earliestObservedEvent === textEvent)
		XCTAssertNil(textEvent.immediatelyPrecedingObservedEvent)
		XCTAssertNotNil(textEvent.immediatelySucceedingObservedEvent)
		XCTAssertFalse(textEvent.latestObservedEvent === textEvent)
		XCTAssertNil(textEvent.immediatelyPrecedingUnobservedEvent)
		XCTAssertTrue(textEvent.immediatelySucceedingUnobservedEvents.isEmpty)
		XCTAssertTrue(textEvent.isEarliestObserved)
		XCTAssertFalse(textEvent.isLatestObserved)
		XCTAssertTrue(textEvent.isObserved)
		XCTAssertFalse(textEvent.isFinalUnobservedEvent)
		XCTAssertFalse(textEvent.isBranchable)
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
		XCTAssertTrue(textEvent.equiStatalSucceedingUnobservedEvents.isEmpty)
		XCTAssertNil(textEvent.outcomeProbabilities["abc"])
		
		//	TODO: Test other types for `State`.
	}
	
	//	TODO: Test more kinds of events:
	//	      earlist non-latest observed events,
	//	      non-earliest non-latest observed events,
	//	      non-earliest latest observed events without unobserved events,
	//	      non-earliest latest observed events with unobserved events,
	//	      non-latest unobserved events at depth 1,
	//	      non-latest unobserved events at depth > 1,
	//	      final unobserved events.
}
