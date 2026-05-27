import ChallengeDeps

theorem isTautology_correct (e : BoolExpr) :
    isTautology e = true ↔ ∀ v : Nat → Bool, eval e v = true :=
  Submission.isTautology_correct e
