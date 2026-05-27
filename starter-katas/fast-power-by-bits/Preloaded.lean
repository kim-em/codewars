-- Slow exponentiation by repeated multiplication.
def slowPow (a : Nat) : Nat → Nat
  | 0     => 1
  | n + 1 => a * slowPow a n

-- Fast exponentiation by squaring. The exponent is given as a list of
-- low-bit-first booleans: `[b₀, b₁, b₂, …]` represents `∑ᵢ bᵢ · 2ⁱ`.
def fastPow (a : Nat) : List Bool → Nat
  | []         => 1
  | false :: l => let r := fastPow a l; r * r
  | true  :: l => let r := fastPow a l; a * r * r

-- Decode a low-bit-first boolean list back to its `Nat` value.
def bitsToNat : List Bool → Nat
  | []         => 0
  | false :: l => 2 * bitsToNat l
  | true  :: l => 2 * bitsToNat l + 1
