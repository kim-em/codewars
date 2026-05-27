-- "Magical" binary operations, after Kostrikin's *Introduction to Algebra*.
structure IsMagical {α : Type} (f : α → α → α) : Prop where
  left  : ∀ x y, f (f x y) y = x
  right : ∀ x y, f y (f y x) = x
