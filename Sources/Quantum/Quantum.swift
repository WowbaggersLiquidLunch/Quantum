//
//	Quantum.swift
//	Quantum
//
//	Created on 2021-01-10.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

/// A quantum mechanical model of the wrapped value.
@propertyWrapper
public struct Quantum<Wrapped: Hashable> {
	
	/// Creates a quantum mechanical system with the given initial state.
	/// - Parameter wrappedValue: The initial state to create a quantum mechanical system with.
	public init(wrappedValue: Wrapped) {
		quantumState = [wrappedValue: 1]
	}
	
	public var wrappedValue: Wrapped {
		mutating get { measurement }
		set(newState) { superpose(on: newState) }
	}
	
	public var projectedValue: Self { self }
	
	/// The probability distribution for the outcomes of each possible measurement on the system.
	public private(set) var quantumState: [Wrapped: Double]
	
	/// The observed state the system is in.
	///
	/// Measuring the outcome collapses the wave function.
	public var measurement: Wrapped {
		mutating get {
			collapseWaveFunction()
			guard
				quantumState.count == 1,
				quantumState.first?.value == 1
			else {
				fatalError("wave function not collapsed on observation")
			}
			return quantumState.first!.key
		}
	}
	
	/// Reduces the wave function to a single eigenstate.
	private mutating func collapseWaveFunction() {
		var cumulativeProbability = Double.random(in: 0...1)
		//	FIXME: There is probably a standard library function that does this.
		for (measurement, probability) in quantumState {
			cumulativeProbability -= probability
			if cumulativeProbability <= 0 {
				quantumState = [measurement: 1]
				break
			}
		}
	}
	
	/// Adds the given state to the superposition.
	/// - Parameter state: The state to add to the superposition.
	public mutating func superpose(on state: Wrapped) {
		quantumState = quantumState.mapValues { $0 / 2 }
		quantumState[state, default: 0] += 0.5
	}
	
	/// Creates a new quantum mechanical system with the superposition of the given state and a copy of the superposition of this system.
	/// - Parameter state: The state to superpose on the copy of the superposition of this system.
	/// - Returns: A new quantum mechanical system with the superposition of the given state and a copy of the superposition of this system.
	@inlinable
	public func superposed(on state: Wrapped) -> Self {
		var newSuperposition = self
		newSuperposition.superpose(on: state)
		return newSuperposition
	}
}
