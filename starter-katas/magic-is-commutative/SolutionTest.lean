import ChallengeDeps

theorem magic_is_commutative {α : Type} (f : α → α → α) (hm : IsMagical f) :
    ∀ x y, f x y = f y x :=
  Submission.magic_is_commutative f hm
