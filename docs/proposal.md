# Proposal: Lean 4 support for Codewars

**Status:** draft. The `codewars-lean4:slim` runner image and the
`Preloaded.lean` / `Solution.lean` / `SolutionTest.lean` adapter
are CI-green end-to-end on a standard `ubuntu-24.04` runner against
v4.30.0 reference examples (see `examples/comparator-direct/` and
`examples/codewars-shape/`). Ready to send to Codewars runner
maintainers.

## The ask

Add Lean 4 (initially `leanprover/lean4:v4.30.0`) as a language in
the Codewars runner. The current Lean entry on
https://docs.codewars.com/languages/lean/ supports only Lean 3 — both
the "3.18.4 with mathlib (78655b6)" and "3.20.0 with mathlib (da66bb8)"
pins — which is end-of-life. No active development has happened in
Lean 3 since 2022 and no path forward for new katas. Lean 4 has been
the production version since 2023 and is what the Lean and Mathlib
communities use.

This repo ships a reproducible runner image and a documented kata
format so the Codewars runner team can adopt Lean 4 without taking
on the maintenance burden of the underlying judging stack.

## One image, core Lean only

| Image                 | Size    | Contents                                                |
|-----------------------|---------|---------------------------------------------------------|
| `codewars-lean4:slim` | 3.85 GB | Lean v4.30.0 + comparator + lean4export + landrun       |

Size measured by CI on a standard `ubuntu-24.04` runner. The Lean
toolchain (core stdlib oleans + Lake) dominates.

### Why no Mathlib image at launch

We prototyped a `codewars-lean4:mathlib` image that bundled mathlib4
v4.30.0 with a pre-built olean cache. The image built and judging
worked correctly under `docker run --network=none`, but per-kata
wall time was unworkable:

| Kata                                | Wall time (CI, 2-core ubuntu-24.04) |
|-------------------------------------|-------------------------------------|
| `import Mathlib` + theorem          | ~50s                                |
| (slim, no Mathlib)                  | ~3s                                 |

Lake walks the full ~8500-job dep graph on every invocation, and the
judging pipeline invokes Lake 3-4 times (workspace_test build, then
comparator's separate Challenge / Solution / replay phases). Each
walk costs ~7-10s of file stats + hash checks at the Mathlib import
size; the per-module compile work itself is only ~5s.

The 50s figure is well past Codewars' documented Lean 3 budget (20s)
and past the slowest documented language on the platform — Scala at
27s, per the legacy
[`codewars-runner-cli/lib/config.js`](https://github.com/Codewars/codewars-runner-cli/blob/master/lib/config.js#L13).

We don't want to ask Codewars to triple the budget for a language we
haven't shipped yet. The Mathlib variant is deferred until either
the comparator pipeline can be flattened (single Lake invocation
across all phases) or surgical-import katas are demonstrated to fit
inside ~10-15s on Codewars' production hardware.

### Implication for the existing Lean 3 corpus

The existing Codewars Lean katas are authored against mathlib3.
With a slim-only launch, those katas can't be auto-ported to Lean 4;
they'd need Mathlib4 and therefore wait on the Mathlib variant. New
Lean 4 katas authored against core Lean (Nat / List / inductive
types / basic algebra) can launch first.

This is a deliberate scope cut, not an oversight. The corpus-migration
plan moves to a phase-2 conversation contingent on solving the
Mathlib wall-time problem.

## What this repo provides

- A Docker image (`docker/Dockerfile.slim`) that installs everything
  the Lean 4 runner needs at pinned SHAs: Lean v4.30.0, comparator,
  lean4export, landrun. ~3.85 GB.
- A `judge` entrypoint (`runner/judge`) that:
  1. Auto-detects which file convention the kata is using.
  2. Translates Codewars-shape katas (`Preloaded.lean` /
     `Solution.lean` / `SolutionTest.lean`) into a comparator
     workspace.
  3. Builds only the trusted `workspace_test` exe outside the
     sandbox; the user's `Submission.lean` is elaborated by
     comparator inside `landrun`.
  4. Emits `<PASSED::>` / `<FAILED::>` / `<ERROR::>` tokens on the
     legacy Codewars runner protocol.
- Pinned, SHA-locked preparation scripts that any operator can re-run
  to rebuild the image deterministically.
- Two worked examples covering both file conventions.
- A documented kata authoring format (`docs/kata-format.md`) and
  trust model (`docs/trust-model.md`).

## Why this is a credible drop-in

The judging stack — `comparator` + `lean4export` + `landrun` — is
already in production use at
https://github.com/kim-em/lean-eval, where it verifies hundreds of
research-grade Lean 4 proofs against a leaderboard at
https://lean-lang.org/eval/. The codewars runner here is a
stripped-down derivative of that infrastructure: same trust model,
same axiom-audit gating, same sandboxing.

For Codewars specifically, we adapt to your existing file convention:
the same `Preloaded.lean` / `Solution.lean` / `SolutionTest.lean`
contract Lean 3 katas use today. Authors who already know how to
write a Codewars Lean 3 kata can author a Lean 4 kata after reading
`docs/kata-format.md`.

## Operational characteristics

- **Image size:** 3.85 GB measured.

- **Runtime budget:** CI measurement on a standard `ubuntu-24.04`
  runner shows ~3s per kata judging (Lean compile + comparator export
  + kernel replay), comfortably inside Codewars' 20s Lean budget.
  Production hardware may be faster than a 2-core GitHub free runner;
  a confirmatory benchmark on Codewars' fleet is the obvious
  follow-up.

- **Network:** the runner needs no network at submission time.
  `docker run --network=none` is verified in CI.

- **User code is sandboxed.** Submissions never elaborate outside
  `landrun`. The `defaultTargets = ["workspace_test"]` setting in the
  workspace `lakefile.toml` ensures `lake build` outside comparator
  builds only the trusted exe — see `docs/trust-model.md` for the
  full anti-cheat surface.

## Maintenance shape

This is a *single Lean version* image. The convention we suggest,
consistent with how Lean works upstream:

- Each Codewars image release pins one Lean toolchain (here `v4.30.0`).
- Katas authored against a given image keep working as long as that
  image is available; Codewars chooses when to roll authors forward.
- New images are produced for new Lean releases (every ~6 weeks).
  Each one ships its own pinned comparator + lean4export.

We're happy to maintain this repo and produce new images at each
upstream Lean release, in exchange for Codewars carrying the
`codewars-lean4:slim` image in the runner stack.

## Discussion points for Codewars

1. **Image hosting.** Where does `codewars-lean4:slim` live? GitHub
   Container Registry under `kim-em/codewars`? Codewars' own registry?
2. **Update cadence.** Who pushes the new image when v4.31.0 lands?
   We propose a Codewars-driven trigger via the runner repo's
   existing language-bump workflow, with us providing the new
   `versions.env` and toolchain pin.
3. **Authoring UI.** Codewars' kata authoring UI for Lean 3 has
   dedicated `Preloaded` / `Solution` / `SolutionTest` panels.
   The simplest integration is to keep those exact panels and tag
   the kata's language as `lean4`. No UI changes needed.
4. **Error display.** The runner currently dumps comparator's full
   stderr and writes a `<FAILED::>` summary line. We can format
   the diagnostic block however Codewars' frontend prefers.
5. **Mathlib roadmap.** New Lean 4 katas at launch are core-only.
   Porting the existing mathlib3 corpus and accepting Mathlib4 katas
   is gated on Mathlib import latency fitting the runtime budget;
   that's a separate piece of work we'll come back with.

## Path forward

If Codewars is interested:

1. Confirm the runner image shape works for your CI integration
   (we can adapt entrypoint conventions if needed).
2. Run a benchmark on Codewars' actual runner hardware. We'll fold
   results back into this proposal.
3. Author 5-10 introductory Lean 4 katas using the convention in
   `docs/kata-format.md` to populate the language launch.
4. Re-open the Mathlib conversation once Mathlib wall time is
   demonstrated to fit the platform's budget.

Contact: Kim Morrison (https://github.com/kim-em).
