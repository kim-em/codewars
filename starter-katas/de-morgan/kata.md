# de Morgan (Lean 4)

**Difficulty:** 6 kyu

Prove the classical de Morgan equivalence:

```lean
theorem not_and_iff_not_or_not (p q : Prop) : ¬(p ∧ q) ↔ ¬p ∨ ¬q
```

The reverse direction is constructive. The forward direction requires
classical reasoning — `by_cases hp : p` splits on whether `p` holds, which
is the natural move here.

The runner permits the standard axioms `propext`, `Quot.sound`, and
`Classical.choice`. The latter makes `Classical.em` and the `by_cases`
tactic available.
