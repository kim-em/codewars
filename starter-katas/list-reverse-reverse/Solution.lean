theorem myReverse_append {α : Type} (l₁ l₂ : List α) :
    myReverse (l₁ ++ l₂) = myReverse l₂ ++ myReverse l₁ := by
  induction l₁ with
  | nil          => simp [myReverse]
  | cons a l ih  => simp [myReverse, ih, List.append_assoc]

theorem myReverse_myReverse {α : Type} (l : List α) :
    myReverse (myReverse l) = l := by
  induction l with
  | nil         => simp [myReverse]
  | cons a l ih => simp [myReverse, myReverse_append, ih]
