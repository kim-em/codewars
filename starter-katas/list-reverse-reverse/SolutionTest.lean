import ChallengeDeps

theorem myReverse_myReverse {α : Type} (l : List α) :
    myReverse (myReverse l) = l :=
  Submission.myReverse_myReverse l
