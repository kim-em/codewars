-- A toy Boolean-expression language: variables (indexed by `Nat`),
-- negation, conjunction, disjunction.
inductive BoolExpr : Type
  | var : Nat → BoolExpr
  | not : BoolExpr → BoolExpr
  | and : BoolExpr → BoolExpr → BoolExpr
  | or  : BoolExpr → BoolExpr → BoolExpr

-- Evaluate an expression under a variable assignment.
def eval : BoolExpr → (Nat → Bool) → Bool
  | .var n,   v => v n
  | .not e,   v => !eval e v
  | .and a b, v => eval a v && eval b v
  | .or  a b, v => eval a v || eval b v

-- One past the highest variable index used by `e`.
def maxVar : BoolExpr → Nat
  | .var n   => n + 1
  | .not e   => maxVar e
  | .and a b => max (maxVar a) (maxVar b)
  | .or  a b => max (maxVar a) (maxVar b)

-- Treat a `List Bool` of length `n` as a `Nat → Bool` by indexing,
-- with `false` past the end of the list.
def asFun : List Bool → Nat → Bool
  | [],      _     => false
  | b :: _,  0     => b
  | _ :: l,  k + 1 => asFun l k

-- All Boolean assignments to `n` variables: `2 ^ n` lists of length `n`.
def allAssignments : Nat → List (List Bool)
  | 0     => [[]]
  | n + 1 => (allAssignments n).flatMap (fun l => [false :: l, true :: l])

-- Brute-force tautology checker: `e` is a tautology iff every assignment
-- to its variables makes `eval e` return `true`.
def isTautology (e : BoolExpr) : Bool :=
  (allAssignments (maxVar e)).all (fun l => eval e (asFun l))
