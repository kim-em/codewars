-- User-submitted proofs. Whatever the user writes here is wrapped in
-- `namespace Submission ... end Submission` to produce Submission.lean.

theorem two_plus_two : (2 : Nat) + 2 = 4 := rfl

theorem add_comm_demo (a b : Nat) : a + b = b + a := Nat.add_comm a b
