theorem mirror_mirror {α : Type} (t : Tree α) : mirror (mirror t) = t := by
  induction t with
  | leaf            => rfl
  | node x l r ihl ihr => simp [mirror, ihl, ihr]
