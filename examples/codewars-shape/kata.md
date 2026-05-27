# Two by Two (Lean 4)

Prove these two basic facts about natural-number addition.

```lean
theorem two_plus_two : (2 : Nat) + 2 = 4 := by sorry

theorem add_comm_demo (a b : Nat) : a + b = b + a := by sorry
```

The first is decidable by reflexivity. The second is `Nat.add_comm`
from Lean's standard library.
