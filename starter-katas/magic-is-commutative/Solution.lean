theorem magic_is_commutative {α : Type} (f : α → α → α) (hm : IsMagical f) :
    ∀ x y, f x y = f y x := by
  intro x y
  -- Two facts about f, abbreviated.
  have L : ∀ a b, f (f a b) b = a := hm.left
  have R : ∀ a b, f b (f b a) = a := hm.right
  -- (1) Apply L to (x, y):  f (f x y) y = x
  have h1 : f (f x y) y = x := L x y
  -- (2) Apply R to (y, f x y):  f (f x y) (f (f x y) y) = y
  --     Substitute (1) into the inner term to get  f (f x y) x = y
  have h2 : f (f x y) x = y := by
    have := R y (f x y)
    rwa [h1] at this
  -- (3) Apply L to (f x y, x):  f (f (f x y) x) x = f x y
  --     Substitute (2) into the inner term to get  f y x = f x y
  have h3 : f y x = f x y := by
    have := L (f x y) x
    rwa [h2] at this
  exact h3.symm
