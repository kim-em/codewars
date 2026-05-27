# Tail-Recursive Sum = Direct Sum (Lean 4)

**Difficulty:** 6 kyu

Two ways to sum a list of naturals:

```lean
def sumDirect : List Nat → Nat
  | []      => 0
  | x :: l  => x + sumDirect l

def sumTail (l : List Nat) : Nat := sumTailHelper l 0
  where
    sumTailHelper : List Nat → Nat → Nat
      | [],     acc => acc
      | x :: l, acc => sumTailHelper l (acc + x)
```

Prove they agree on every list.

```lean
theorem sumTail_eq_sumDirect (l : List Nat) : sumTail l = sumDirect l
```

The direct induction on `l` fails because the inductive hypothesis is too
specific. The fix is a generalised lemma over an arbitrary accumulator:

```lean
sumTailHelper l acc = acc + sumDirect l
```

Prove that one first by `induction l generalizing acc`, then apply it with
`acc = 0` to close the main theorem.
