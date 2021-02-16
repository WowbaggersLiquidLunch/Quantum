//
//	QuantumEvent.swift
//	Quantum
//
//	Created on 2021-01-10.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

///	An instantaneous event that might have happened and moved a quantum mechanical system from one state to another state.
///	- Note: Currently interlacing of observed and unobserved events is not supported. An event tree must start with an observed event, followed by an uninterrupted chain of observed events, until the first unobserved event. No observed event can follow from an unobserved event.
public final class QuantumEvent<State: Hashable> {
	
	//	TODO: Remove this type-alias declaration once support for `Self` lands for final classes.
	//	[SR-11176](https://bugs.swift.org/browse/SR-11176)
	public typealias `Self` = QuantumEvent<State>
	
	///	Creates an event that might have happened.
	///	- Parameters:
	///	  - state: The state the event moves the system to.
	///	  - previmmediatelyPrecedingEventiousEvent: The event that this event follows right after.
	public init(arrivingAt state: State, following immediatelyPrecedingEvent: Self? = nil) {
		self.state = state
		self.immediatelyPrecedingEvent = immediatelyPrecedingEvent
		self.isObserved = immediatelyPrecedingEvent == nil
	}
	
	//	MARK: -
	
	///	The state the event (might have) moved the system to.
	///
	///	If the event is observed to have happened, then the system is known to be in this state at the end of the event, until the next event.
	public let state: State
	
	//	MARK: -
	
	public private(set) var immediatelyPrecedingEvent: Self? {
		didSet {
			if oldValue != nil {
				//	Once there is an immediately preceding event, there always is.
				immediatelyPrecedingEvent = oldValue
			}
		}
	}
	
	///	The event that is observed to have started the system at its earliest known state.
	///
	///	When there is only one observed event, `earliestObservedEvent === latestObservedEvent`.
	///
	///	- Complexity: O(_m_ + log _n_), where _m_ is the number of observed events, and _n_ is the number of unobserved events in the event-tree.
	@inlinable
	public var earliestObservedEvent: Self {
		immediatelyPrecedingEvent?.earliestObservedEvent ?? self
	}
	
	///	The observed event that this event follows right after.
	///
	///	`nil` is returned for the earliest observed event and unobserved events other than those immediately following right after the latest observed events.
	@inlinable
	public var immediatelyPrecedingObservedEvent: Self? {
		immediatelyPrecedingEvent?.isObserved ?? false ? immediatelyPrecedingEvent : nil
	}
	
	///	The observed event that follows right after this event.
	///
	///	`nil` is returned for the latest observed events and all unobserved events.
	public private(set) var immediatelySucceedingObservedEvent: Self? {
		didSet {
			if oldValue != nil {
				immediatelySucceedingObservedEvent = oldValue
			} else {
				immediatelySucceedingUnobservedEvents = []
			}
		}
	}
	
	///	The latest observed event.
	///
	///	When there is only one observed event, `earliestObservedEvent === latestObservedEvent`.
	///
	///	- Complexity: O(_m_ + log _n_), where _m_ is the number of observed events, and _n_ is the number of unobserved events in the event-tree.
	@inlinable
	public var latestObservedEvent: Self {
		isObserved
			? immediatelySucceedingObservedEvent?.latestObservedEvent ?? self
			: immediatelyPrecedingUnobservedEvent?.latestObservedEvent ?? immediatelyPrecedingObservedEvent!
	}
	
	///	The unobserved event that this event follows right after.
	///
	///	`nil` is returned for all observed events and unobserved events that immediately follow right after the latest observed events.
	@inlinable
	public var immediatelyPrecedingUnobservedEvent: Self? {
		if let immediatelyPrecedingEvent = immediatelyPrecedingEvent, !immediatelyPrecedingEvent.isObserved {
			return immediatelyPrecedingEvent
		} else {
			return nil
		}
	}
	
	///	The unobserved events that follows right after this event.
	///
	///	An empty array is returned for all non-latest observed events and all final unobserved events.
	public private(set) var immediatelySucceedingUnobservedEvents: [Self] = [] {
		didSet {
			if immediatelySucceedingObservedEvent != nil {
				immediatelySucceedingUnobservedEvents = []
			}
		}
	}
	
	//	MARK: - Inspecting the Event
	
	///	A `Boolean` value indicating whether the event is observed to have happened.
	public private(set) var isObserved: Bool {
		didSet(wasObserved) {
			if wasObserved {
				//	Once observed, an event can not be unobserved.
				isObserved = true
			}
		}
	}
	
	///	A `Boolean` value indicating whether the event is observed to have started the system at its earliest known state.
	@inlinable
	public var isEarliestObserved: Bool {
		isObserved && immediatelyPrecedingObservedEvent == nil
	}
	
	///	A `Boolean` value indicating whether the event is the latest observed event.
	@inlinable
	public var isLatestObserved: Bool {
		isObserved && immediatelySucceedingObservedEvent == nil
	}
	
	///	A `Boolean` value indicating whether the event is an unobserved event without other unobserved events following right after it.
	@inlinable
	public var isFinalUnobservedEvent: Bool {
		!isObserved && immediatelySucceedingUnobservedEvents.isEmpty
	}
	
	///	A `Boolean` value indicating whether the event can have unobserved events following right after it.
	@inlinable
	public var isBranchable: Bool {
		immediatelySucceedingObservedEvent == nil
	}
	
	//	MARK: - Inspecting the System
	
	///	The chain of observed events from the earliest observed event through the immediately preceding observed events.
	///
	///	An empty array is returned for the earliest observed event and all unobserved events except fo those following right after the latest observed event.
	///
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	@inlinable
	public var precedingObservedEvents: [Self] {
		if let immediatelyPrecedingObservedEvent = immediatelyPrecedingObservedEvent {
			return immediatelyPrecedingObservedEvent.precedingObservedEvents + [immediatelyPrecedingObservedEvent]
		} else {
			return []
		}
	}
	
	///	The chain of observed events from the immediately succeeding observed events through the latest observed event.
	///
	///	An empty array is returned for the latest observed event and all unobserved events.
	///
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	@inlinable
	public var succeedingObservedEvents: [Self] {
		if let immediatelySucceedingObservedEvent = immediatelySucceedingObservedEvent {
			return immediatelySucceedingObservedEvent.succeedingObservedEvents + [immediatelySucceedingObservedEvent]
		} else {
			return []
		}
	}
	
	///	The chain of unobserved events leading to this event.
	///
	///	An empty array is returned for all observed events and unobserved events that follow right after the latest observed event.
	///
	///	- Complexity: O(log _n_), where _n_ is the number of unobserved events in the tree.
	@inlinable
	public var precedingUnobservedEvents: [Self] {
		if let immediatelyPrecedingUnobservedEvent = immediatelyPrecedingUnobservedEvent {
			return immediatelyPrecedingUnobservedEvent.precedingUnobservedEvents + [immediatelyPrecedingUnobservedEvent]
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
		if !isBranchable {
			return []
		} else {
			return immediatelySucceedingUnobservedEvents.reduce(into: []) { succeedingUnobservedEvents, immediatelySucceedingUnobservedEvent in
				succeedingUnobservedEvents.append(immediatelySucceedingUnobservedEvent)
				succeedingUnobservedEvents.append(contentsOf: immediatelySucceedingUnobservedEvent.succeedingUnobservedEvents)
			}
		}
	}
	
	///	All observed events
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	@inlinable
	public var allObservedEvents: [Self] {
		[earliestObservedEvent] + earliestObservedEvent.succeedingObservedEvents
	}
	
	///	All unobserved events.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	@inlinable
	public var allUnobservedEvents: [Self] {
		latestObservedEvent.succeedingUnobservedEvents
	}
	
	///	The final event and all unobserved events.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	@inlinable
	public var allBranchableEvents: [Self] {
		[latestObservedEvent] + allUnobservedEvents
	}
	
	///	All observed events that have moved the system to the same state as this event does.
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	@inlinable
	public var equiStatalObservedEvents: [Self] {
		allObservedEvents.filter { $0.state == state }
	}
	
	///	All succeeding observed events that have moved the system to the same state as this event does.
	///	- Complexity: O(_n_), where _n_ is the number of observed events in the tree.
	@inlinable
	public var equiStatalSucceedingObservedEvents: [Self] {
		succeedingObservedEvents.filter { $0.state == state }
	}
	
	///	All branchable events that can move the system to the same state as this event does.
	///	- Complexity: O(log _n_) on average and O(_n_) in worst case, where _n_ is the number of events in the event-tree.
	@inlinable
	public var equiStatalBranchableEvents: [Self] {
		allBranchableEvents.filter { $0.state == state }
	}
	
	///	All unobserved events that move the system to the same state as this event does.
	///	- Complexity: O(log _n_) on average and O(_n_) in worst case, where _n_ is the number of events in the event-tree.
	@inlinable
	public var equiStatalUnobservedEvents: [Self] {
		allUnobservedEvents.filter { $0.state == state }
	}
	
	///	All succeeding unobserved events that can moved the system to the same state as this event does.
	///	- Complexity: O(log _n_) on average and O(_n_) in worst case, where _n_ is the number of events in the event-tree.
	@inlinable
	public var equiStatalSucceedingUnobservedEvents: [Self] {
		succeedingUnobservedEvents.filter { $0.state == state }
	}
	
	//	MARK: -
	
	///	Branches off this event (and optionally its equi-statal events) with new and distinct events that move the system to the given state.
	///	- Complexity: O(1), if `withEquiStatalBranchableEvents == false`; otherwise, O(_n_), where _n_ is the number of unobserved events in the tree.
	///	- Parameters:
	///	  - nextState: The state the new events are to move the system to.
	///	  - withEquiStatalBranchableEvents: A `Boolean` value indicating whether this event's equi-statal events should be branched off with new events.
	public func move(to nextState: State, withEquiStatalBranchableEvents: Bool = false) {
		guard isBranchable && state != nextState else { return }
		if withEquiStatalBranchableEvents {
			for branchableEvent in equiStatalBranchableEvents {
				branchableEvent.move(to: nextState)
			}
		} else {
			let newUnobservedEvent = Self(arrivingAt: nextState, following: self)
			immediatelySucceedingUnobservedEvents.append(newUnobservedEvent)
		}
	}
	
	///	Branches off all succeeding unobserved events (and optionally this event) with new and distinct events that move the system to the given state.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	///	- Parameters:
	///	  - nextState: The state the new events are to move the system to.
	///	  - withThisEvent: A `Boolean` value indicating whether this event should be branched off with new events.
	@inlinable
	public func moveSucceedingUnobservedEvents(to nextState: State, withThisEvent: Bool = false/*, withEquiStatalBranchableEvents: Bool = false*/) {
		for unobservedEvent in succeedingUnobservedEvents {
			unobservedEvent.move(to: nextState)
		}
		if withThisEvent {
			move(to: nextState)
		}
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
				event.immediatelyPrecedingEvent = self
				event.isObserved = true
				break
			}
			probabilisticWeightOfNextEvent /= 2
		}
		immediatelySucceedingUnobservedEvents = []
	}
	
	///	The probability distribution for the outcomes of measuring the system at its present state, if this event is assumed to have happened.
	///	- Complexity: O(_n_) on average, where _n_ is the number of unobserved events in the tree.
	public var outcomeProbabilities: [State: Double] {
		if !isBranchable {
			return latestObservedEvent.outcomeProbabilities
		} else {
			return outcomeProbabilities(probabilitySpaceSize: 1)
		}
	}
	
	///	Calculates the probability distribution for the outcomes of measuring the system at its present state, if the given event is assumed to have happened.
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the tree.
	///	- Parameter probabilitySpaceSize: The total size of the probability space to be shared by all possible states. Use maximum value, `1`, if the assumed probability of `event` happening is 100%.
	///	- Returns: The probability distribution for the outcomes of measuring the system at its present state, if the given event is assumed to have happened.
	private func outcomeProbabilities(probabilitySpaceSize: Double = 1) -> [State: Double] {
		var subProbabilitySpaceSize = probabilitySpaceSize
		var probailityDistribution: [State: Double] = [:]
		for immediatelySucceedingUnobservedEvent in immediatelySucceedingUnobservedEvents {
			subProbabilitySpaceSize /= 2
			let subProbabilityDistribution = immediatelySucceedingUnobservedEvent.outcomeProbabilities(probabilitySpaceSize: subProbabilitySpaceSize)
			for (state, probability) in subProbabilityDistribution {
				probailityDistribution[state, default: 0] += probability
			}
		}
		//	<#Explain#>
		probailityDistribution[state, default: 0] += subProbabilitySpaceSize
		return probailityDistribution
	}
}
