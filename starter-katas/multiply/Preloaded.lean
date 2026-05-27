-- A recursive multiplication on `Nat`, defined by induction on the first
-- argument. The kata asks you to prove this matches `Nat.*`.
def multiply : Nat → Nat → Nat
  | 0,     _ => 0
  | n + 1, m => m + multiply n m
