//
//	QuantumEvent.swift
//	Quantum
//
//	Created on 2022-02-22.
//	Copyleft © 2022 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

public final class QuantumEvent<State> {
	//	FIXME: Remove this type-alias declaration once support for `Self` lands for final classes.
	//	[SR-11176](https://bugs.swift.org/browse/SR-11176)
	//	Once we have effectful writable computed properties and after this has become an actor, then remove this type-alias declaration once `Self` is allowed on actors.
	//	[SR-15448](https://bugs.swift.org/browse/SR-15448)
	public typealias `Self` = QuantumEvent<State>
	
	public enum Mutation {
		case destination(State)
		case path(() -> State/*, entanglementLifetime: EntanglementLifetime*/)
		case selfReferencingPath((State) -> State/*, entanglementLifetime: EntanglementLifetime*/)
	}
	
	public enum Precondition {
		case event(QuantumEvent<State>)
		case state(State)
	}
	
	public enum EntanglementLifetime {
		case instantaneous
		case persistent
		case eternal
	}
	
	public let mutation: Mutation
	
	let precondition: Precondition?
	
	init(
		movedTo state: State,
		immediatelyAfter precondition: Precondition? = nil
	) {
		mutation = .destination(state)
		self.precondition = precondition
	}
	
	init(
		movement: @autoclosure @escaping () -> State,
		immediatelyAfter precondition: Precondition? = nil/*,
		entanglementLifetime: EntanglementLifetime = .persistent*/
	) {
		mutation = .path(movement/*, entanglementLifetime: entanglementLifetime*/)
		self.precondition = precondition
	}
	
	init(
		movement: @escaping (State) -> State,
		immediatelyAfter precondition: Precondition? = nil/*,
		entanglementLifetime: EntanglementLifetime = .persistent*/
	) {
		mutation = .selfReferencingPath(movement/*, entanglementLifetime: entanglementLifetime*/)
		self.precondition = precondition
	}
}

extension QuantumEvent {
	public static func state(
		_ state: State,
		immediatelyAfter precondition: Precondition? = nil
	) -> Self {
		Self(movedTo: state, immediatelyAfter: precondition)
	}
	
	public static func movement(
		_ movement: @autoclosure @escaping () -> State,
		immediatelyAfter precondition: Precondition? = nil/*,
		entanglementLifetime: EntanglementLifetime*/
	) -> Self {
		Self(movement: movement(), immediatelyAfter: precondition/*, entanglementLifetime: entanglementLifetime*/)
	}
	
	public static func movement(
		_ movement: @escaping (State) -> State,
		immediatelyAfter precondition: Precondition? = nil/*,
		entanglementLifetime: EntanglementLifetime*/
	) -> Self {
		Self(movement: movement, immediatelyAfter: precondition/*, entanglementLifetime: entanglementLifetime*/)
	}
}

