# Trust model

This document describes what Codewars' operators have to trust to run
Lean 4 katas, and what they don't.

## What Codewars must trust

1. **The Lean kernel** (shipped as part of the
   `leanprover/lean4:v4.30.0` toolchain). This is the same trust
   assumption every Lean 4 proof rests on.

2. **The toolchain build** — i.e. that the elan-distributed
   `leanprover/lean4:v4.30.0` Linux binaries actually correspond to
   the source at that tag. This is standard for any Lean deployment.

3. **`comparator`** (https://github.com/leanprover/comparator) at
   pinned SHA `1cfc5d8a…` and **`lean4export`**
   (https://github.com/leanprover/lean4export) at pinned SHA
   `a3e35a58…`. Both are written and maintained by the Lean FRO.
   Their role is to compare the user's proof of each theorem against
   the kata author's *statement* of that theorem, and to enforce
   that only allowlisted axioms are used.

4. **`landrun`** (https://github.com/Zouuup/landrun) at pinned SHA
   `5ed4a3db…`. A small Go wrapper around Linux Landlock that
   sandboxes the user's Lean elaboration. Builds the user's
   `Submission.lean` with a restricted filesystem view — read-only
   nix store / standard libs, read-write only its own tempdir.

5. **The kata author's `Preloaded.lean` and `SolutionTest.lean`** for
   each kata. These are the human-auditable parts: they define the
   problem. Codewars already trusts kata authors today for Lean 3
   katas in exactly this sense.

## What Codewars does NOT need to trust

- **The submitter's `Solution.lean`**. Comparator + landrun together
  ensure that even maliciously crafted submissions can't:

  - Forge a proof of the statement (comparator checks the proof
    against the trusted statement via `lean4export` and the kernel).

  - Bypass the axiom allowlist (comparator audits every transitive
    dependency for any axiom outside `permitted_axioms`).

  - Escape the build environment (landrun restricts filesystem and
    process privileges during elaboration).

- **The contents of `~/.elan/`, `~/.lake/`, or anything else under the
  judge user's `$HOME`**, beyond the toolchain itself. The runner
  works with a fresh `/tmp/codewars-lean4-XXXXX` workspace per
  submission and discards it after the verdict.

## Anti-cheat surface

The comparator-based pipeline closes off the major Lean 4 cheat
vectors:

| Vector                                | Defended by              |
|---------------------------------------|--------------------------|
| `sorry` in proof body                 | `permitted_axioms` audit |
| Adding a local `axiom` declaration    | same                     |
| `native_decide` with rigged native    | same                     |
| `Lean.ofReduceBool` rigged native     | same                     |
| `@[implemented_by]` overriding a fn   | same (axiom audit catches the rigged const) |
| Macros that elaborate IO              | landrun filesystem sandbox |
| Reading the test file from disk      | landrun filesystem sandbox |
| `unsafe def` calling unverified C    | axiom audit (`unsafe` is itself a flag comparator inspects) |

Vectors that comparator alone does NOT close, and which therefore
remain in scope for future hardening (tracked in
`docs/proposal.md` as follow-ups, not MVP blockers):

- **Resource exhaustion during elaboration.** Comparator runs Lean
  inside landrun, but landrun does not impose memory/CPU limits on
  its own. Codewars' container-level limits (cgroups) still apply,
  but a malicious submission could try to time out the build.

- **Workspace tampering via Lake macros.** A kata using a custom
  `lakefile.toml` could in principle inject Lake-level customizations.
  We mitigate by always overwriting the workspace's `lakefile.toml`
  and `WorkspaceTest.lean` with the template versions during
  adaptation (codewars-shape mode); comparator-direct mode is
  author-trusted.

- **Toolchain-version pinning attacks.** A submission can't change
  `lean-toolchain` mid-build, but a kata author could pin a vulnerable
  Lean version. The runner overwrites `lean-toolchain` with the
  workspace-template's pin (`v4.30.0`); kata authors get one Lean
  version per runner image.

## Why we chose comparator over simpler heuristics

Earlier in the design we considered cheaper guards (regex for
`sorry`/`axiom`, `#print axioms` audit, warnings-as-errors compile).
The trouble with all of those: Lean 4's metaprogramming surface lets a
sufficiently determined cheater hide forbidden axioms behind macros,
generated declarations, or names that look innocuous to a regex.

Comparator gets a structural proof — it exports both Challenge and
Solution via `lean4export` and replays them through the kernel — so
the trust story doesn't depend on heuristic scans of source text.
That's worth the ~5s of cold-start cost it adds.
