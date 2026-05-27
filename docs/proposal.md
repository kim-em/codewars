# Proposal: Lean 4 support for Codewars

**Status:** draft. The `codewars-lean4:slim` and `codewars-lean4:mathlib`
runner image recipes and the `Preloaded.lean` / `Solution.lean` /
`SolutionTest.lean` adapter work end-to-end against v4.30.0 reference
examples (see `examples/comparator-direct/`, `examples/codewars-shape/`,
and `examples/mathlib-shape/`). A clean-machine Docker build benchmark
on the mathlib variant is the missing piece before this is ready to
send to the Codewars runner maintainers.

## The ask

Add Lean 4 (initially `leanprover/lean4:v4.30.0`) as a language in
the Codewars runner. The current Lean entry on
https://docs.codewars.com/languages/lean/ supports only Lean 3 — both
the "3.18.4 with mathlib (78655b6)" and "3.20.0 with mathlib (da66bb8)"
pins — which is end-of-life. No active development has happened in
Lean 3 since 2022 and no path forward for new katas. Lean 4 has been
the production version since 2023 and is what the Lean and Mathlib
communities use.

This repo ships reproducible runner images and a documented kata
format so the Codewars runner team can adopt Lean 4 without taking
on the maintenance burden of the underlying judging stack.

## Two images, both at v4.30.0

| Image                          | Size        | Contents                                                              |
|--------------------------------|-------------|-----------------------------------------------------------------------|
| `codewars-lean4:slim`          | ~3.85 GB    | Lean v4.30.0 + comparator + lean4export + landrun                     |
| `codewars-lean4:mathlib`       | ~10 GB est. | slim + mathlib4 v4.30.0 with a verified-complete olean cache          |

Slim size is measured by CI on the actual `Dockerfile.slim`
(https://github.com/kim-em/codewars/actions/runs/26521756301). The
toolchain itself is the dominant cost — Lean's distribution includes
core stdlib oleans and Lake. The mathlib estimate is projected from
mathlib4's documented olean cache (~6 GB) on top of the measured slim
base; will be replaced with a measurement once the mathlib image is
built in CI.

The Lean 3 corpus on Codewars today is authored against mathlib3
(see https://docs.codewars.com/languages/lean/). Existing katas that
import mathlib can't be migrated to a pure-Lean Lean 4 image; they
need Mathlib4. Shipping both images at launch lets Codewars:

1. Take new Lean 4 katas authored against core (fast, small image).
2. Port the existing mathlib3-based katas into Lean 4 + Mathlib4 katas
   (slower import, large image, but the corpus survives).

Kata authors choose by picking which image their kata targets — the
metadata is one field. The runner shares the same `judge` entrypoint
across both, so Codewars' runner team integrates one binary, not two.

## What this repo provides

- Two Docker images (`docker/Dockerfile.slim`, `docker/Dockerfile.mathlib`)
  that install everything the Lean 4 runner needs at pinned SHAs:
  Lean v4.30.0, comparator, lean4export, landrun, plus mathlib4 v4.30.0
  in the mathlib variant.
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
  to rebuild either image deterministically.
- Three worked examples covering both file conventions and both image
  variants.
- A documented kata authoring format (`docs/kata-format.md`) and
  trust model (`docs/trust-model.md`).

## Why this is a credible drop-in

The judging stack — `comparator` + `lean4export` + `landrun` — is
already in production use at
https://github.com/kim-em/lean-eval, where it verifies hundreds of
research-grade Lean 4 proofs against a leaderboard at
https://lean-lang.org/eval/. The codewars runner here is a
stripped-down derivative of that infrastructure: same trust model,
same axiom-audit gating, same sandboxing, same mathlib version pin
pattern.

For Codewars specifically, we adapt to your existing file convention:
the same `Preloaded.lean` / `Solution.lean` / `SolutionTest.lean`
contract Lean 3 katas use today. Authors who already know how to
write a Codewars Lean 3 kata can author a Lean 4 kata after reading
`docs/kata-format.md`. Mathlib-using katas work the same way; the
only difference is the kata's `Preloaded.lean` imports something
from Mathlib.

## Operational characteristics

- **Image sizes:** slim measures at ~3.85 GB in CI; mathlib variant
  is projected at ~10 GB, with mathlib's olean cache adding ~6 GB
  on top. The mathlib image builds FROM slim, so the slim image is
  a strict subset.

- **Runtime budget:** comparator's cold-start cost on a pre-built
  workspace is the figure that needs to fit inside Codewars'
  documented 20s Lean timeout. On the slim image, local measurement
  on `examples/comparator-direct/two-plus-two` shows ~2-3s per
  judging (Lean compile + comparator export + kernel replay), well
  inside budget. On the mathlib image, `import Mathlib` is the
  dominant cost — single-digit seconds with a warm cache, more on
  cold start.

  Both need to be reconfirmed inside the production Codewars
  container. A benchmark step lives in `scripts/benchmark.sh` and
  runs during `docker build` via `verify-installation.sh`. Numbers
  will be added here before final submission.

  Mitigation for mathlib's import cost: kata authors can import
  specific Mathlib submodules (e.g. `import Mathlib.Data.Real.Basic`)
  instead of `import Mathlib` to cut load time substantially. The
  worked mathlib example shows the convenient form; documentation
  recommends the surgical form for production katas.

- **Network:** neither runner needs network at submission time.
  `docker run --network=none` is supported and used in the
  verification kata. Mathlib is bundled as a path-dep, not pulled
  by Lake at runtime.

- **User code is sandboxed.** Submissions never elaborate outside
  `landrun`. The `defaultTargets = ["workspace_test"]` setting in the
  workspace `lakefile.toml` ensures `lake build` outside comparator
  builds only the trusted exe — see `docs/trust-model.md` for the
  full anti-cheat surface.

## Maintenance shape

This is a *single Lean version, single Mathlib version* image pair.
The convention we suggest, consistent with how Lean and Mathlib work
upstream:

- Each Codewars image release pins one Lean toolchain (here `v4.30.0`)
  and, for the mathlib variant, one Mathlib commit at the matching
  tag.
- Katas authored against a given image keep working as long as that
  image is available; Codewars chooses when to roll authors forward.
- New images are produced for new Lean releases (every ~6 weeks).
  Each one ships its own pinned comparator + lean4export, and the
  mathlib variant ships the matching Mathlib tag.

We're happy to maintain this repo and produce new images at each
upstream Lean release, in exchange for Codewars carrying the
`codewars-lean4:slim` and `codewars-lean4:mathlib` images in the
runner stack. The path-forward section at the end of this document
lays out the proposed cadence.

## Discussion points for Codewars

These are the points we'd expect to land on with the runner team
during review:

1. **Image hosting.** Where do `codewars-lean4:slim` and
   `codewars-lean4:mathlib` live? GitHub Container Registry under
   `kim-em/codewars`? Codewars' own registry?
2. **Update cadence.** Who pushes the new images when v4.31.0 lands?
   We propose a Codewars-driven trigger via the runner repo's
   existing language-bump workflow, with us providing the new
   `versions.env` (pinning Lean, Mathlib, and the toolchain SHAs).
3. **Authoring UI.** Codewars' kata authoring UI for Lean 3 has
   dedicated `Preloaded` / `Solution` / `SolutionTest` panels.
   The simplest integration is to keep those exact panels and add
   one new field: `lean4-image: slim | mathlib`. Defaults to slim
   for new katas; corpus-migration of existing katas defaults to
   mathlib.
4. **The 20s budget.** Subject to benchmark confirmation, this
   should be enough for slim katas. For mathlib katas it's tighter;
   if production hardware doesn't make it, we propose raising to
   30s for mathlib-variant katas specifically.
5. **Error display.** The runner currently dumps comparator's full
   stderr and writes a `<FAILED::>` summary line. We can format
   the diagnostic block however Codewars' frontend prefers.
6. **Corpus migration.** Are existing mathlib3-based Lean 3 katas in
   scope for a mass-port effort? The kata authors are the obvious
   first line; if you'd like us to organize a port-a-thon among the
   Lean community, that's a separate conversation we're up for.

## Path forward

If Codewars is interested:

1. Confirm the runner image shape works for your CI integration
   (we can adapt entrypoint conventions if needed).
2. Run a benchmark on Codewars' actual runner hardware for both
   images. We'll fold results back into this proposal.
3. Author 5-10 introductory Lean 4 katas using the convention in
   `docs/kata-format.md` to populate the language launch (mix of
   slim and mathlib variants).
4. Coordinate corpus migration of existing Lean 3 katas, starting
   with the most-attempted ones.

Contact: Kim Morrison (https://github.com/kim-em).
