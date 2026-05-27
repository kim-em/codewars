import ChallengeDeps

theorem fastPow_eq (a : Nat) (l : List Bool) :
    fastPow a l = slowPow a (bitsToNat l) :=
  Submission.fastPow_eq a l
