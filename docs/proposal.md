# Proposal: Lean 4 support for Codewars

**Status:** draft. The `codewars-lean4:slim` runner image and the
`Preloaded.lean` / `Solution.lean` / `SolutionTest.lean` adapter
work end-to-end against a v4.30.0 reference example
(see `examples/comparator-direct/` and `examples/codewars-shape/`).
A clean-machine Docker build benchmark is the missing piece before
this is ready to send to the Codewars runner maintainers.

## The ask

Add Lean 4 (initially `leanprover/lean4:v4.30.0`) as a language in
the Codewars runner. The current Lean entry on
https://docs.codewars.com/languages/lean/ supports only Lean 3,
which is end-of-life — no active development since 2022 and no path
forward for new katas. Lean 4 has been the production version since
2023 and is what the Lean and Mathlib communities use.

This repo ships a reproducible runner image and a documented kata
format so the Codewars runner team can adopt Lean 4 without taking
on the maintenance burden of the underlying judging stack.

## What this repo provides

- A Docker image (`docker/Dockerfile`) that installs everything the
  Lean 4 runner needs at pinned SHAs: Lean v4.30.0, comparator,
  lean4export, landrun. ~1 GB target size.
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

- **Image size:** target <1 GB. Slim variant only; no Mathlib.
- **Runtime budget:** comparator's cold-start cost on a pre-built
  workspace is the figure that needs to fit inside Codewars'
  documented 20s Lean timeout. Local benchmark on
  `examples/comparator-direct/two-plus-two` shows ~2-3s per
  judging (Lean compile + comparator export + kernel replay), well
  inside budget for a pure-Lean kata.

  This needs to be reconfirmed inside the production Codewars
  container — a benchmark step is in `scripts/benchmark.sh` and runs
  during `docker build` via `verify-installation.sh`. Numbers will be
  added here before submission.

- **Network:** the runner needs no network at submission time.
  `docker run --network=none` is supported and used in the
  verification kata.

- **User code is sandboxed.** Submissions never elaborate outside
  `landrun`. The `defaultTargets = ["workspace_test"]` setting in the
  workspace `lakefile.toml` ensures `lake build` outside comparator
  builds only the trusted exe — see `docs/trust-model.md` for the
  full anti-cheat surface.

## Maintenance shape

This image is a *single Lean version* image. The convention we
suggest, consistent with how Lean and Mathlib work upstream:

- Each Codewars image release pins one Lean toolchain (here
  `v4.30.0`).
- Katas authored against a given image keep working as long as that
  image is available; Codewars chooses when to roll authors forward.
- New images are produced for new Lean releases (every ~6 weeks).
  Each one ships its own pinned comparator + lean4export.

We're happy to maintain this repo and produce new images at each
upstream Lean release, in exchange for Codewars carrying the
`codewars-lean4:slim` image in the runner stack. The path-forward
section at the end of this document lays out the proposed cadence.

## What's deferred to phase 2

The original scope of this repo briefly contemplated a Mathlib
variant. After a design review (preserved in the commit log) we
deferred it. The reasons:

- A Mathlib-bundled image is 6–8 GB, which is a much larger
  operational ask of Codewars than the slim image.
- Cold-start Mathlib import latency is ~5–10s on a warm cache, more
  on cold; that's close to the documented 20s budget without leaving
  room for the user's proof.
- Most introductory Lean 4 katas don't need Mathlib — basic algebra
  and inductive types on `Nat` / `List` are surface enough to host
  dozens of katas.

Phase 2 lands when there's traffic on the slim image and a clear
case for the size/budget cost.

## Discussion points for Codewars

These are the points we'd expect to land on with the runner team
during review:

1. **Image hosting.** Where does `codewars-lean4:slim` live?
   GitHub Container Registry under `kim-em/codewars`? Codewars'
   own registry?
2. **Update cadence.** Who pushes the new image when v4.31.0 lands?
   We propose a Codewars-driven trigger via the runner repo's
   existing language-bump workflow, with us providing the new
   `versions.env` and toolchain pin.
3. **Authoring UI.** Codewars' kata authoring UI for Lean 3 has
   dedicated `Preloaded` / `Solution` / `SolutionTest` panels.
   The simplest integration is to keep those exact panels and tag
   the kata's language as `lean4`. No UI changes needed for MVP.
4. **The 20s budget.** Subject to benchmark confirmation, this
   should be enough. If it's not on Codewars' production hardware,
   we propose raising it to 30s for Lean 4 specifically.
5. **Error display.** The runner currently dumps comparator's full
   stderr and writes a `<FAILED::>` summary line. We can format
   the diagnostic block however Codewars' frontend prefers.

## Path forward

If Codewars is interested:

1. Confirm the runner image shape works for your CI integration
   (we can adapt entrypoint conventions if needed).
2. Run a benchmark on Codewars' actual runner hardware. We'll fold
   results back into this proposal.
3. Author 5-10 introductory Lean 4 katas using the convention in
   `docs/kata-format.md` to populate the language launch.
4. Decide on phase 2 (Mathlib image) timing based on traffic and
   author demand.

Contact: Kim Morrison (https://github.com/kim-em).
