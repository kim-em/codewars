-- Two ways to sum a list of natural numbers.

-- Direct (non-tail-recursive) sum.
def sumDirect : List Nat → Nat
  | []      => 0
  | x :: l  => x + sumDirect l

-- Tail-recursive sum, with an accumulator.
def sumTailHelper : List Nat → Nat → Nat
  | [],     acc => acc
  | x :: l, acc => sumTailHelper l (acc + x)

def sumTail (l : List Nat) : Nat := sumTailHelper l 0
