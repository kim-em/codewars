# Reverse Twice (Lean 4)

**Difficulty:** 7 kyu

A direct list reverse, defined by structural recursion:

```lean
def myReverse {α : Type} : List α → List α
  | []      => []
  | a :: l  => myReverse l ++ [a]
```

Prove that reversing twice is the identity.

## What you must provide

In your `Solution.lean`, prove:

```lean
theorem myReverse_myReverse {α : Type} (l : List α) :
    myReverse (myReverse l) = l
```

You will need a helper lemma about `myReverse` distributing over `++` in the
opposite order: `myReverse (l₁ ++ l₂) = myReverse l₂ ++ myReverse l₁`.
