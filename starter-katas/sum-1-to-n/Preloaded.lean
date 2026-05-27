-- The sum of the first `n` positive integers, defined by recursion.
def sumTo : Nat → Nat
  | 0     => 0
  | n + 1 => (n + 1) + sumTo n
