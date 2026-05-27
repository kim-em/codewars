-- A predicate-level definition of evenness: `n` is even iff it's twice
-- some other natural number.
def Even (n : Nat) : Prop := ∃ k, n = 2 * k

-- A decidable, computable version of the same predicate. Computes by
-- recursion on the structure of `n`, peeling off pairs of `+1`s.
def isEven : Nat → Bool
  | 0     => true
  | 1     => false
  | n + 2 => isEven n
