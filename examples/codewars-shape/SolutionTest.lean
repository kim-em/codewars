import ChallengeDeps

-- Trusted theorem statements. Each top-level `theorem` must have its
-- body refer to `Submission.<same-name>`; the adapter rewrites each
-- body to `by sorry` to produce Challenge.lean.

theorem two_plus_two : (2 : Nat) + 2 = 4 := Submission.two_plus_two

theorem add_comm_demo (a b : Nat) : a + b = b + a := Submission.add_comm_demo a b
