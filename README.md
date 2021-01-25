# Quantum

This package allows variables to behave in a quantum mechanical way.

A quantum mechanical variable can be created in 2 ways:

1. Via `Quantum`'s initialiser directly.

   ```swift
   var quantumText = Quantum("Schrödinger")
   ```

2. Via the `@Quantum` annotation.
   ```swift
   @Quantum
   var quantumNumber = 0
   ```

Variables governed by quantum mechanics behave differently from those governed by classical mechanics. For a classical mechanical system, it is possible to predict the present state if its past states and movements are known (determinism), and vice versa (reversibility). On the contrary, for a quantum mechanical system, it is impossible to predict its state at any point in time; its present state is unknown until observed.

```swift
quantumNumber = 1
quantumNumber = 2
quantumNumber = 3

print($quantumNumber.outcomeProbability)
//	Prints "[0: 0.125, 1: 0.125, 2: 0.25, 3: 0.5]".

print(quantumNumber)
//	Prints "0", "1", "2", or "3".
//	All for values are possible.
```

---

This library, and everything included in this directory is released both to the public domain (through the Unlicense license) and under the MIT license. The user is free to choose either license. In general, public domain is preferred, unless the circumstance dictates otherwise. For more information, see [LICENSE](LICENSE).

![Unlicense icon](https://upload.wikimedia.org/wikipedia/commons/6/62/PD-icon.svg)
