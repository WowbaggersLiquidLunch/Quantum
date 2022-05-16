//
//	Quantum.swift
//	Quantum
//
//	Created on 2022-02-22.
//	Copyleft © 2022 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Collections

@propertyWrapper
public final class Quantum<State> {
	public typealias `Self` = Quantum<State>
	
	/// <#Description#>
	public typealias MutationChain = Deque<QuantumEvent<State>>
	/// <#Description#>
	public var unobservedMutationChain: MutationChain
	public var persistentMutationChain: MutationChain
	
	public convenience init(wrappedValue: State) {
		self.init(initialState: wrappedValue)
	}
	
	public init(initialState: State) {
		self.initialState = initialState
		self.intermediateState = initialState
		unobservedMutationChain = []
		persistentMutationChain = []
	}
	
	public private(set) var initialState: State
	public private(set) var intermediateState: State
	
	public var wrappedValue: State {
		get { observed() }
		set { unobservedMutationChain.append(.movement(newValue)) }
	}
	
	public var projectedValue: Self {
		get { self }
	}
}

extension Quantum {
//	public mutating func observe(until quantumEvent: QuantumEvent<State>) {
//
//	}
	
	public func observe() {
		intermediateState = initialState
		
		func transit(toNewStateVia mutation: QuantumEvent<State>.Mutation) {
			switch mutation {
			case let .destination(state): intermediateState = state
			case let .path(movement): intermediateState = movement()
			case let .selfReferencingPath(movement): intermediateState = movement(intermediateState)
			}
		}
		
		for quantumEvent in persistentMutationChain {
			transit(toNewStateVia: quantumEvent.mutation)
		}
		
		for quantumEvent in unobservedMutationChain where Bool.random() {
			transit(toNewStateVia: quantumEvent.mutation)
		
			switch quantumEvent.mutation {
			case .destination:
				initialState = intermediateState
				persistentMutationChain = [quantumEvent]
			default:
				persistentMutationChain.append(quantumEvent)
			}
		}
		
		unobservedMutationChain = []
	}
	
	public func observed() -> State {
		observe()
		return intermediateState
	}
}
