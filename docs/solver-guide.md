# Solver guide for Lean 4 katas

This is the user-facing companion to a Lean 4 kata on Codewars. It answers
the common "I got a weird error, why?" questions and gives you a workflow
for solving locally so you don't burn Codewars attempts on infrastructure
problems.

## Quick contract

When you open a Lean 4 kata, Codewars shows you three files:

| File              | Who writes it     | What it does                                |
|-------------------|-------------------|---------------------------------------------|
| `Preloaded.lean`  | Kata author       | Trusted definitions you'll prove things about. **Read-only.** |
| `Solution.lean`   | **You**           | Your proofs go here. Edit freely.           |
| `SolutionTest.lean` | Kata author     | Trusted theorem statements. **Read-only.**  |

When you submit, the runner does these things to your `Solution.lean`:

1. Wraps it in `namespace Submission ... end Submission`.
2. Adds `import ChallengeDeps` at the top.

That's it. You write your theorems and helper lemmas in the open, and the
runner namespaces them for you. **Do not write `namespace Submission`
yourself** — it would nest inside the runner's, producing
`Submission.Submission.foo`, and the spec won't find your theorem.

## What's available

- **Lean v4.30.0**, exactly. Update with each new image.
- **Core Lean 4 only.** No Mathlib, no batteries.
- The standard tactics are all there: `simp`, `rw`, `omega`, `decide`,
  `induction`, `cases`, `rfl`, `exact`, `apply`, `refine`, `constructor`,
  `obtain`, `rintro`, `intro`, `have`, `show`, `calc`, `by_cases`, ...
- `omega` handles **linear** arithmetic over `Nat` and `Int`. It does
  *not* handle nonlinear products like `n * (n+1)`. For polynomial
  identities you'll need explicit `Nat.mul_add` / `Nat.mul_comm` rewrites.
- Strong induction on `Nat`: `induction n using Nat.strongRecOn with | ind n ih => ...`
  (note: not `Nat.strong_induction_on` — that's a Lean 3 name).

## Forbidden axioms

The judge permits exactly three axioms in your proof:

- `propext` (propositional extensionality)
- `Quot.sound` (quotient soundness)
- `Classical.choice` (classical logic — `by_cases`, `Classical.em`, `byContra`)

Anything else is rejected, including `sorryAx` (`sorry` / `admit`),
`Lean.ofReduceBool` and `Lean.ofReduceNat` (`native_decide`), and any
custom `axiom` you might be tempted to write.

## Failure modes you'll hit

### `<FAILED::>Your solution still uses sorry`

You left a `sorry` or `admit` in `Solution.lean`. Replace every
placeholder with a real proof.

### `<FAILED::>Your proof depends on the axiom \`...\`...`

You used a tactic that depends on a forbidden axiom. The usual suspects:

- `native_decide` (depends on `Lean.ofReduceBool` / `Lean.ofReduceNat`)
- A handwritten `axiom foo : Bar`

Find the offending line and replace with a proof that uses only the
permitted axioms.

### `<FAILED::>The runner expected a theorem named \`foo\`...`

Your declaration name doesn't match what the spec asks for. Open
`SolutionTest.lean`; the theorem name there is what your `Solution.lean`
must define. Case-sensitive.

### `<FAILED::>Your proof tried \`rfl\` but the two sides are not definitionally equal`

`rfl` only works when both sides reduce to the same normal form. If the
definition in `Preloaded.lean` is recursive (most are), `rfl` is too weak
— you'll need induction.

### `<FAILED::>Type mismatch in your proof`

Lean's type-checker rejected a step. The actual Lean error appears in the
trace above the verdict line. Common cases: wrong number of arguments,
wrong universe, accidentally using `=` where `↔` was expected.

### `<FAILED::>The runner doesn't bundle Mathlib`

You wrote `import Mathlib.Something` (or imported anything outside core
Lean 4). This image doesn't ship Mathlib. Stick to core Lean.

## Notes on errors pointing at "Submission.lean"

When the runner reports an error at e.g. `Submission.lean:5`, it's
referring to your `Solution.lean` *after* the wrapper added two lines at
the top (`import ChallengeDeps`, blank, `namespace Submission`, blank).
So `Submission.lean:5` is roughly your `Solution.lean:1`. Likewise
`Submission.lean:N` ≈ your `Solution.lean:N-4`.

## Solving locally

Codewars submissions are slow and have an attempt counter. Solve
locally first, then paste once your proof compiles.

### Setup (one-time)

```bash
# Install elan if you don't have it.
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
# Install the kata's toolchain.
elan toolchain install leanprover/lean4:v4.30.0
```

### Workflow

1. Create a working directory:
   ```bash
   mkdir my-kata && cd my-kata
   ```
2. Drop in a `lean-toolchain` file:
   ```
   leanprover/lean4:v4.30.0
   ```
3. Save the kata's `Preloaded.lean` as `Preloaded.lean`. Make sure its
   declarations are accessible at the top level. (No namespace.)
4. Write your `Solution.lean` *inside* a `namespace Submission`:
   ```lean
   import «Preloaded»

   namespace Submission

   -- your proofs here

   end Submission
   ```
5. Open in VS Code with the Lean 4 extension, or run `lake build` if
   you set up a Lake project. The errors you'd see on Codewars appear
   in your editor immediately.
6. Once it compiles, copy the body of your `namespace Submission ...
   end Submission` block (without the namespace lines themselves)
   into Codewars' `Solution.lean` box.

## Why is comparator the judge?

Lean 3 katas trusted the tester to define the kata's tests in a
sandboxed runtime. Lean 4 katas use **comparator**: it builds your
solution inside a sandbox (landrun), exports both the kata's trusted
spec and your proof, and verifies via the Lean kernel that you've
proved the *same* theorem the spec states, using only the permitted
axioms.

The upshot: the trust story is simpler. The kata author writes one
trusted spec; you write a proof; comparator confirms they match. There's
no test framework to game, no hidden cases, no "find an edge that breaks
their tests." If `comparator` accepts your proof, the kernel accepted it.

## More

- Repository: <https://github.com/kim-em/codewars>
- Comparator: <https://github.com/leanprover/comparator>
- Lean kata format reference: [`docs/kata-format.md`](kata-format.md)
- Trust model: [`docs/trust-model.md`](trust-model.md)
