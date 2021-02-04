//
//	QuantumEvent.swift
//	Quantum
//
//	Created on 2021-01-10.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

///	An instantaneous event that might have happened and moved a quantum mechanical system from one state to another state.
public final class QuantumEvent<State: Hashable> {
	
	//	TODO: Remove this type-alias declaration once support for `Self` lands for final classes.
	//	[SR-11176](https://bugs.swift.org/browse/SR-11176)
	public typealias `Self` = QuantumEvent<State>
	
	///	Creates an event that might have happened.
	///	- Parameters:
	///	  - arrivalState: The state the event moves the system to.
	///	  - immediatelyPrecedingEvent: The event that this event follows right after.
	public init(arrivingAt arrivalState: State, following immediatelyPrecedingEvent: Self? = nil) {
		state = arrivalState
		guard let immediatelyPrecedingEvent = immediatelyPrecedingEvent else { return }
		if immediatelyPrecedingEvent.isObservedEvent {
			immediatelyPrecedingObservedEvent = immediatelyPrecedingEvent
		} else {
			immediatelyPrecedingUnobservedEvent = immediatelyPrecedingEvent
		}
	}
	
	//	MARK: -
	
	///	The state the event (might have) moved the system to.
	///
	///	If the event is observed to have happened, then the system is known to be in this state at the end of the event, until the next event.
	public let state: State
	
	//	MARK: -
	
	///	The event that is observed to have started the system at an initial state.
	///
	///	When there is only one observed event, `initialObservedEvent === initialObservedEvent`.
	///
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the event-tree.
	@inlinable
	public var initialObservedEvent: Self {
		immediatelyPrecedingObservedEvent?.initialObservedEvent ?? self
	}
	
	///	The observed event that this event follows right after.
	///
	///	`nil` is returned for the initial observed event and unobserved events other than those immediately following right after the final observed events.
	public private(set) var immediatelyPrecedingObservedEvent: Self? {
		didSet {
			if oldValue != nil {
				immediatelyPrecedingObservedEvent = oldValue
			}
		}
	}
	
	///	The observed event that follows right after this event.
	///
	///	`nil` is returned for the final observed events and all unobserved events.
	public private(set) var immediatelySucceedingObservedEvent: Self? {
		didSet {
			if oldValue != nil {
				immediatelySucceedingObservedEvent = oldValue
			} else {
				immediatelySucceedingUnobservedEvents = []
			}
		}
	}
	
	///	The final observed event.
	///
	///	When there is only one observed event, `initialObservedEvent === initialObservedEvent`.
	///
	///	- Complexity: O(log _n_) on average and O(_n_) in worst case, where _n_ is the number of events in the event-tree.
	@inlinable
	public var finalObservedEvent: Self {
		//	If there is an observed event that follows right after this event, then find the final observed event through it.
		if let immediatelySucceedingObservedEvent = immediatelySucceedingObservedEvent {
			return immediatelySucceedingObservedEvent.finalObservedEvent
		//	If there isn't an observed event that follows right after this event, then this event is either the final observed event, or an unobserved event.
		//	If the event right before this event is unobserved, then find the final observed event from it.
		} else if let immediatelyPrecedingUnobservedEvent = immediatelyPrecedingUnobservedEvent {
			return immediatelyPrecedingUnobservedEvent.finalObservedEvent
		//	If the event right before this event is observed, then this event is either the final observed event, or an unobserved event that follows right after the final observed event.
		} else if let immediatelyPrecedingObservedEvent = immediatelyPrecedingObservedEvent {
			//	If the observed event right before this even has no observed event that follows right after it, then it's the final observed event.
			if immediatelyPrecedingObservedEvent.immediatelySucceedingObservedEvent == nil {
				return immediatelyPrecedingObservedEvent
			//	Otherwise, this event is the final observed event.
			} else {
				return self
			}
		//	Otherwise, this event is the final observed event.
		} else {
			return self
		}
	}
	
	///	The unobserved event that this event follows right after.
	///
	///	`nil` is returned for all observed events and unobserved events that immediately follow right after the final observed events.
	public private(set) var immediatelyPrecedingUnobservedEvent: Self? = nil {
		didSet {
			if oldValue == nil {
				immediatelyPrecedingUnobservedEvent = nil
			}
		}
	}
	
	///	The unobserved events that follows right after this event.
	///
	///	An empty array is returned for all non-final observed events and all final unobserved events.
	public private(set) var immediatelySucceedingUnobservedEvents: [Self] = [] {
		didSet {
			if immediatelySucceedingObservedEvent != nil {
				immediatelySucceedingUnobservedEvents = []
			}
		}
	}
	
	//	MARK: - Inspecting an Event
	
	///	A `Boolean` value indicating whether the event is observed to have happened.
	@inlinable
	public var isObservedEvent: Bool {
		!isUnobservedEvent
	}
	
	///	A `Boolean` value indicating whether the event is yet to have been observed to have happened.
	@inlinable
	public var isUnobservedEvent: Bool {
		isBranchableEvent && self !== finalObservedEvent
	}
	
	///	A `Boolean` value indicating whether the event is observed to have started the system at an initial state.
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the event-tree.
	@inlinable
	public var isInitialObservedEvent: Bool {
		self === initialObservedEvent
	}
	
	///	A `Boolean` value indicating whether the event is the final observed event.
	///	- Complexity: O(log _n_) on average and O(_n_) in worst case, where _n_ is the number of events in the event-tree.
	@inlinable
	public var isFinalObservedEvent: Bool {
		self === finalObservedEvent
	}
	
	///	A `Boolean` value indicating whether the event is an unobserved event without other unobserved events following right after it.
	@inlinable
	public var isFinalUnobservedEvent: Bool {
		isUnobservedEvent && immediatelySucceedingUnobservedEvents.isEmpty
	}
	
	///	A `Boolean` value indicating whether the event can have unobserved events following right after it.
	@inlinable
	public var isBranchableEvent: Bool {
		immediatelySucceedingObservedEvent == nil
	}
	
	//	MARK: - Inspecting the System
	
	///	The chain of observed events from the initial observed event through the immediately preceding observed events.
	///
	///	An empty array is returned for the initial observed event and all unobserved events except fo those following right after the final observed event.
	///
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	@inlinable
	public var precedingObservedEvents: [Self] {
		if let immediatelyPrecedingObservedEvent = immediatelyPrecedingObservedEvent {
			var _precedingObservedEvents = immediatelyPrecedingObservedEvent.precedingObservedEvents
			_precedingObservedEvents.append(immediatelyPrecedingObservedEvent)
			return _precedingObservedEvents
		} else {
			return []
		}
	}
	
	///	The chain of observed events from the immediately succeeding observed events through the final observed event.
	///
	///	An empty array is returned for the final observed event and all unobserved events.
	///
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	@inlinable
	public var succeedingObservedEvents: [Self] {
		if let immediatelySucceedingObservedEvent = immediatelySucceedingObservedEvent {
			var _succeedingObservedEvents = immediatelySucceedingObservedEvent.succeedingObservedEvents
			_succeedingObservedEvents.append(immediatelySucceedingObservedEvent)
			return _succeedingObservedEvents
		} else {
			return []
		}
	}
	
	///	The chain of unobserved events leading to this event.
	///
	///	An empty array is returned for all observed events and unobserved events that follow right after the final observed event.
	///
	///	- Complexity: O(log _n_), where _n_ is the number of unobserved events in the tree.
	@inlinable
	public var precedingUnobservedEvents: [Self] {
		if let immediatelyPrecedingUnobservedEvent = immediatelyPrecedingUnobservedEvent {
			var _precedingUnobservedEvents = immediatelyPrecedingUnobservedEvent.precedingUnobservedEvents
			_precedingUnobservedEvents.append(immediatelyPrecedingUnobservedEvent)
			return _precedingUnobservedEvents
		} else {
			return []
		}
	}
	
	///	All unobserved events that require this event to be observed if any of them is to be observed.
	///
	///	An empty array is returned for all final unobserved events.
	///
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	@inlinable
	public var succeedingUnobservedEvents: [Self] {
		if !isBranchableEvent {
			return allUnobservedEvents
		}
		var _succeedingUnobservedEvents: [Self] = []
		for immediatelySucceedingUnobservedEvent in immediatelySucceedingUnobservedEvents {
			_succeedingUnobservedEvents.append(immediatelySucceedingUnobservedEvent)
			_succeedingUnobservedEvents.append(contentsOf: immediatelySucceedingUnobservedEvent.succeedingUnobservedEvents)
		}
		return _succeedingUnobservedEvents
	}
	
	///	All unobserved events.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	@inlinable
	public var allUnobservedEvents: [Self] {
		finalObservedEvent.succeedingUnobservedEvents
	}
	
	///	The final event and all unobserved events.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	@inlinable
	public var allBranchableEvents: [Self] {
		var _allBranchableEvents = allUnobservedEvents
		_allBranchableEvents.append(finalObservedEvent)
		return _allBranchableEvents
	}
	
	///	All observed events that move the system to the same state as this event does.
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	public var equiStatalObservedEvents: [Self] {
		var _equiStatalObservedEvents: [Self] = []
		if initialObservedEvent.state == state {
			_equiStatalObservedEvents.append(initialObservedEvent)
		}
		_equiStatalObservedEvents.append(contentsOf: initialObservedEvent.succeedingObservedEvents(movingTo: state))
		return _equiStatalObservedEvents
	}
	
	///	Returns the chain of observed events that happened after this event and moved the system to the given state.
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	///	- Parameter state: The given state that the the observed events moved the system to.
	///	- Returns: An array containing observed events that happened after this event and moved the system to the given state.
	private func succeedingObservedEvents(movingTo state: State) -> [Self] {
		guard let immediatelySucceedingObservedEvent = immediatelySucceedingObservedEvent else { return [] }
		var succeedingObservedEventsMovingToGivenState: [Self] = []
		if immediatelySucceedingObservedEvent.state == state {
			succeedingObservedEventsMovingToGivenState = [immediatelySucceedingObservedEvent]
		}
		succeedingObservedEventsMovingToGivenState.append(contentsOf: immediatelySucceedingObservedEvent.succeedingObservedEvents(movingTo: state))
		return succeedingObservedEventsMovingToGivenState
	}
	
	///	All branchable events that move the system to the same state as this event does.
	///	- Complexity: O(log _n_) on average and O(_n_) in worst case, where _n_ is the number of events in the event-tree.
	@inlinable
	public var equiStatalBranchableEvents: [Self] {
		var _equiStatalBranchableEvents: [Self] = []
		if finalObservedEvent.state == state {
			_equiStatalBranchableEvents.append(finalObservedEvent)	//	<#Explain#>
		}
		_equiStatalBranchableEvents.append(contentsOf: equiStatalUnobservedEvents)
		return _equiStatalBranchableEvents
	}
	
	///	All unobserved events that move the system to the same state as this event does.
	///	- Complexity: O(log _n_) on average and O(_n_) in worst case, where _n_ is the number of events in the event-tree.
	public var equiStatalUnobservedEvents: [Self] {
		finalObservedEvent.succeedingUnobservedEvents(movingTo: state)
	}
	
	///	Returns the chain of unobserved events that possibly happened after this event and moved the system to the given state.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	///	- Parameter state: The state that the the unobserved events moved the system to, if they had happened.
	///	- Returns: An array containing unobserved events that possibly happened after this event and moved the system to the given state.
	private func succeedingUnobservedEvents(movingTo state: State) -> [Self] {
		var succeedingUnobservedEventsMovingToGivenState: [Self] = []
		for immediatelySucceedingUnobservedEvent in immediatelySucceedingUnobservedEvents {
			if immediatelySucceedingUnobservedEvent.state == state {
				succeedingUnobservedEventsMovingToGivenState.append(immediatelySucceedingUnobservedEvent)
			}
			succeedingUnobservedEventsMovingToGivenState.append(contentsOf: immediatelySucceedingUnobservedEvent.succeedingUnobservedEvents(movingTo: state))
		}
		return succeedingUnobservedEventsMovingToGivenState
	}
	
	//	MARK: -
	
	///	Branches off this event (and optionally its equi-statal events) with new and distinct events that move the system to the given state.
	///	- Complexity: O(1), if `withEquiStatalBranchableEvents == false`; otherwise, O(_n_), where _n_ is the number of unobserved events in the tree.
	///	- Parameters:
	///	  - nextState: The state the new events are to move the system to.
	///	  - withEquiStatalBranchableEvents: A `Boolean` value indicating whether this event's equi-statal events should be branched off with new events.
	public func move(to nextState: State, withEquiStatalBranchableEvents: Bool = false) {
		guard isBranchableEvent && state != nextState else { return }
		if withEquiStatalBranchableEvents {
			for branchableEvent in equiStatalBranchableEvents {
				Self.move(branchableEvent, to: nextState)
			}
		} else {
			Self.move(self, to: nextState)
		}
	}
	
	///	Branches off all succeeding unobserved events (and optionally this event) with new and distinct events that move the system to the given state.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	///	- Parameters:
	///	  - nextState: The state the new events are to move the system to.
	///	  - withThisEvent: A `Boolean` value indicating whether this event should be branched off with new events.
	public func moveSucceedingUnobservedEvents(to nextState: State, withThisEvent: Bool = false/*, withEquiStatalBranchableEvents: Bool = false*/) {
		for unobservedEvent in succeedingUnobservedEvents {
			Self.move(unobservedEvent, to: nextState)
		}
		if withThisEvent {
			Self.move(self, to: nextState)
		}
	}
	
	///	Branches off the given event with a new event that moves the system to the given state.
	///	- Parameters:
	///	  - event: The event to branch off from.
	///	  - nextState: The state the new event is to move the system to.
	private static func move(_ event: Self, to nextState: State) {
		guard event.isBranchableEvent && event.state != nextState else { return }
		let newUnobservedEvent = Self(arrivingAt: nextState, following: event)
		event.immediatelySucceedingUnobservedEvents.append(newUnobservedEvent)
	}
	
	//	MARK: - Observing the System
	
	///	Observe which of the events that follows right after this event actually happened.
	///
	///	It is possible that none of the events have happened.
	///
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events that follow right after this event.
	public func observeNextEvent() {
		var coinToss = Double.random(in: 0..<1)
		var probabilisticWeightOfNextEvent = 0.5
		for event in immediatelySucceedingUnobservedEvents {
			coinToss -= probabilisticWeightOfNextEvent
			if coinToss < 0 {
				immediatelySucceedingObservedEvent = event
				event.immediatelyPrecedingObservedEvent = self
				event.immediatelyPrecedingUnobservedEvent = nil
				for nextEvent in event.immediatelySucceedingUnobservedEvents {
					nextEvent.immediatelyPrecedingObservedEvent = event
				}
				break
			}
			probabilisticWeightOfNextEvent /= 2
		}
		immediatelySucceedingUnobservedEvents = []
	}
	
	///	The probability distribution for the outcomes of measuring the system at its present state, if this event is assumed to have happened.
	///	- Complexity: O(_n_) on average, where _n_ is the number of unobserved events in the tree.
	public var outcomeProbabilities: [State: Double] {
		if !isBranchableEvent {
			return finalObservedEvent.outcomeProbabilities
		} else {
			return Self.probailityDistribution(ofOutcomeSucceeding: self, probabilitySpaceSize: 1)
		}
	}
	
	///	Calculates the probability distribution for the outcomes of measuring the system at its present state, if the given event is assumed to have happened.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	///	- Parameters:
	///	  - event: The event that is assumed to have happened.
	///	  - probabilitySpaceSize: The total size of the probability space to be shared by all possible states. Use maximum value, `1`, if the assumed probability of `event` happening is 100%.
	///	- Returns: The probability distribution for the outcomes of measuring the system at its present state, if the given event is assumed to have happened.
	private static func probailityDistribution(ofOutcomeSucceeding event: Self, probabilitySpaceSize: Double = 1) -> [State: Double] {
		var probailityDistribution: [State: Double] = [:]
		var subProbabilitySpaceSize = probabilitySpaceSize
		for immediatelySucceedingUnobservedEvent in event.immediatelySucceedingUnobservedEvents {
			subProbabilitySpaceSize /= 2
			let subProbabilityDistribution = Self.probailityDistribution(ofOutcomeSucceeding: immediatelySucceedingUnobservedEvent, probabilitySpaceSize: subProbabilitySpaceSize)
			for (state, probability) in subProbabilityDistribution {
				probailityDistribution[state, default: 0] += probability
			}
		}
		//	<#Explain#>
		probailityDistribution[event.state, default: 0] += subProbabilitySpaceSize
		return probailityDistribution
	}
	
}
