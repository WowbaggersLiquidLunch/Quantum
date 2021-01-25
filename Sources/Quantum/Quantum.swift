//
//	Quantum.swift
//	Quantum
//
//	Created on 2021-01-10.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

///	A quantum mechanical system whose state is unknown until observed.
///
///	At any point in time, a system is in a state. It takes an event to move a system from a state at one point in time to another state at the next point in time. For a classical mechanical system, it is possible to predict the present state if its past states and movements are known (determinism), and vice versa (reversibility). On the contrary, for a quantum mechanical system, it is impossible to predict its state at any point in time; its present state is unknown until observed. Similarly, an event that moves a quantum mechanical system from one state to another is not known to have happened until observed.
///
///	A quantum mechanical system can be created directly, via one of `Quantum`'s initialisers.
///
///	```swift
///	var quantumText = Quantum(initialState: "wave–particle duality")
///	```
///
///	Or, it can be create by annotating `@Quantum` to the declaration of a variable of a `Hashable`-conforming type.
///
///	```swift
///	@Quantum
///	var schrödingersNumber = 0
///	```
///
///	A `Quantum` instance's present state can be observed via its `measurement` computed property, and a `@Quantum`-wrapped variable can be observed reading it directly or via any getter.
///
///	```swift
///	print(quantumText.measurement)
///	//	Prints "wave–particle duality", the only possible state at this point in time.
///
///	print(schrödingersNumber)
///	//	Prints 0, the only possible state at this point in time.
///	```
///
///	Accessing Events
///	----------------
///
///	Under the surface, a `Quantum` instance is represented by a rooted tree of events, where the root is the initial observed event (the initialisation of the instance<!--TODO: <#Add exception for entangled initilisation#>-->). The tree starts with a chain of observed events that ends at the final observed event, which branches into trees of unobserved events. The final observed event of a `Quantum` instance can be accessed directly, and all other events can be accessed via it:
///
///	```swift
///	let finalObservedTextEvent = quantumText.finalObservedEvent
///	let initialObservedTextEvent = initialObservedTextEvent.initialObservedEvent
///
///	let finalObservedNumberEvent = $schrödingersNumber.finalObservedEvent
///	let nextUnobservedNumberEvents = finalObservedNumberEvent.immediatelySucceedingUnobservedEvents
///	```
///
///	A system can arrive at a state through many possible chains of events; many events can move the system to the same state. Although, only one chain would have happened on observation, if the system was indeed in the state.
///
///	One event-chain may contain another event-chain, because a system's states may repeat. However, events never form a loop or cycle, because the arrow of time flies unidirectionally.
///
///	Moving a Quantum Mechanical System
///	----------------------------------
///
///	When a quantum mechanical system moves from all its possible but unobserved states to a (new) possible state _A_, it's said that the system is superposed on _A_. When such a superposition happens, all unobserved events not already resulting in _A_ in the event-tree, along the final observed event, branch off with new and distinct events moving the system to _A_. A `Quantum` instance can move to a new possible state via the `superpose(on:)` method, and `@Quantum`-wrapped variables can be moved through any setter or assignment:
///
///	```swift
///	quantumText.superpose(on: "uncertainty principle")
///	//	At this point in time, quantumText.measurement has
///	//	    50% probability for "wave–particle duality",
///	//	and 50%                 "uncertainty principle".
///	quantumText.superpose(on: "optical comb")
///	//	At this point in time, quantumText.measurement has
///	//	    25% probability for "wave–particle duality",
///	//	    25%                 "uncertainty principle",
///	//	and 50%                 "optical comb".
///
///	$schrödingersNumber.superpose(on: 1)
///	//	At this point in time, schrödingersNumber has
///	//	    50% probability for 0,
///	//	and 50%                 1.
///	schrödingersNumber = 2
///	//	At this point in time, schrödingersNumber has
///	//	    25% probability for 0,
///	//	    25%                 1,
///	//	and 50%                 2.
///	```
///
///	Additionally, a quantum mechanical system can be moved from one particular possible but unobserved state _B_ to a different state _C_. With such a movement, only _B_, instead of the entire system, is superposed on _C_. Because there are many possible event-chains that lead to _B_, all unobserved events moving the system to _B_ must branch off with new and distinct events moving the system to _C_. This kind of state-specific superposition is possible through `superpose(_:on:)`:
///
///	```swift
///	quantumText.superpose("uncertainty principle", on: "potential barrier")
///	//	At this point in time, quantumText.measurement has
///	//	    25.0% probability for "wave–particle duality",
///	//	    12.5%                 "uncertainty principle",
///	//	    25.0%                 "optical comb",
///	//	and 12.5%                 "potential barrier".
///
///	$schrödingersNumber.superpose(2, on: 3)
///	//	At this point in time, schrödingersNumber has
///	//	    25% probability for 0,
///	//	    25%                 1,
///	//	    25%                 2,
///	//	and 25%                 3.
///	```
///
///	Accessing a System's Present State's Probability Distribution
///	-------------------------------------------------------------
///
///	Although a quantum mechanical system's present state is unknown until observed, the probability distribution for the outcome of measuring the system at its present state is known. This information is accessible through the `outcomeProbabilities` computed property:
///
///	```swift
///	print(quantumText.outcomeProbabilities)
///	//	Prints '["wave–particle duality": 0.25, "uncertainty principle": 0.125, "optical comb": 0.25, "potential barrier": 0.125]'.
///	print($schrödingersNumber.outcomeProbabilities)
///	//	Prints "[0: 0.25, 1: 0.25, 2: 0.25, 3: 0.25]".
///	```
///
///	Once a quantum mechanical system is observed, and before it's moved again, the present state's probability distribution is the observed state at 100% probability:
///
///	```swift
///	print(quantumText.measurement)
///	//	Prints "optical comb", one of the possible states.
///	print(quantumText.outcomeProbabilities)
///	//	Prints '["optical comb": 1]'
///
///	print(schrödingersNumber)
///	//	Prints 0, one of the possible states.
///	print($schrödingersNumber.outcomeProbabilities)
///	//	Prints "[0: 1]"
///	```
///
///	- Note: `State` must be a value type. Otherwise the state's probability distribution can't be correctly calculated, due to a limitation of `Dictionary.subscript(_:default:)`.
@propertyWrapper
public struct Quantum<State: Hashable> {
	
	///	Creates a quantum mechanical system with the given initial state.
	///	- Parameter initialState: The initial state of the system.
	public init(initialState: State) {
		finalObservedEvent = Event(arrivingAt: initialState)
	}
	
	//	MARK: - Property Wrapper
	
	///	Creates the quantum mechanical system with the given initial wrapped state.
	///	- Parameter wrappedValue: The initial wrapped state of the system.
	public init(wrappedValue: State) {
		self.init(initialState: wrappedValue)
	}
	
	@inlinable
	public var wrappedValue: State {
		mutating get { measurement }
		set(newState) { superpose(on: newState) }
	}
	
	//	FIXME: Make `projectedValue` immutable.
	@inlinable
	public var projectedValue: Self {
		get { self }
		set { self = newValue }
	}
	
	//	MARK: -
	
	//	FIXME: Keep unsafeMutableSelf mutable without mutating `projectedValue`.
	@inlinable
	public var unsafeMutableSelf: Self {
		get { self }
		set { self = newValue }
	}
	
	public typealias Event = QuantumEvent<State>
	
	///	The final one in the chain of observed events.
	///
	///	This event moved the system to its final observed state.
	public private(set) var finalObservedEvent: Event
	
	///	The probability distribution for the outcome of measuring the system at its present state.
	///	- Complexity: O(_n_) where _n_ is the number of unobserved events in the event-tree.
	///	- Note: The probabilities are represented as `Double` values. Because the probabilities are always multiples of 2⁻ⁿ less than or equal to 1, where n is a positive integer, the probabilities are guaranteed to be precise if and only if the longest chain of unobserved events (excluding the final observed event) has at most 106 events.
	///	  > Explanation: There are 52 fraction bits in `Double`, so all fractions that are multiples of 2⁻⁵³ and less than or equal to 1 can be precisely represented. Because no 2 consecutive events can move the system to the same state in any event-chain, it takes at least 106 events in a chain to give 1 state a probability of 1 - 2⁻⁵³.
	@inlinable
	public var outcomeProbabilities: [State: Double] {
		finalObservedEvent.outcomeProbabilities
	}
	
	///	The state the system is in.
	///
	///	Accessing this property is equivalent to observing the system.
	///
	///	- Complexity: O(log _n_) in the general case and O(_n_) worst case, where _n_ is the number of unobserved events in the event-tree.
	public var measurement: State {
		mutating get {
			while !finalObservedEvent.immediatelySucceedingUnobservedEvents.isEmpty {
				finalObservedEvent.observeNextEvent()
				finalObservedEvent = finalObservedEvent.finalObservedEvent
			}
			return finalObservedEvent.state
		}
	}
	
	///	Superposes the system's all possible states on the given state.
	///
	///	This superposition works by branching off all unobserved events not already resulting in `state` in the event-tree, along the final observed event, with new and distinct events that move the system to `state`.
	///
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the event-tree.
	///
	///	- Parameter state: The given state to superpose on.
	@inlinable
	public mutating func superpose(on state: State) {
		finalObservedEvent.moveSucceedingUnobservedEvents(to: state, withThisEvent: true)
	}
	
	///	Superposes one of the system's possible states on the given state.
	///
	///	This superposition works by branching off all unobserved events moving the system to `possibleState` with new and distinct events moving the system to `nextState`.
	///
	///	- Complexity: O(_n_), where _n_ is the number of unobserved events in the event-tree.
	///
	///	- Parameters:
	///	  - possibleState: The possible state of the system to superpose on the given state.
	///	  - nextState: The given state to superpose on.
	@inlinable
	public mutating func superpose(_ possibleState: State, on nextState: State) {
		guard let oneOfPossibleEvents = finalObservedEvent.allBranchableEvents.first(where: { $0.state == possibleState } ) else { return }
		oneOfPossibleEvents.move(to: nextState, withEquiStatalBranchableEvents: true)
	}
	
	///	Creates a new quantum mechanical system from the superposition of this system on the given state.
	///	- Parameter state: The given state to superpose on.
	///	- Returns: A new quantum mechanical system equivalent to the superposition of this system on the given state.
	@inlinable
	public func superposed(on state: State) -> Self {
		var newSuperposition = self
		newSuperposition.superpose(on: state)
		return newSuperposition
	}
	
}
