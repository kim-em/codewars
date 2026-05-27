# codewars-lean4

Reproducible scaffolding for adding Lean 4 support to
[Codewars](https://www.codewars.com).

Codewars currently supports
[only Lean 3](https://docs.codewars.com/languages/lean/). Lean 3 is
end-of-life. This repo packages everything Codewars' runner team would
need to drop Lean 4 into their infrastructure:

- pinned toolchain (`leanprover/lean4:v4.30.0`),
- pinned build of [`comparator`](https://github.com/leanprover/comparator)
  + [`lean4export`](https://github.com/leanprover/lean4export) +
  [`landrun`](https://github.com/Zouuup/landrun) (the judging stack
  proven in [`lean-eval`](https://github.com/kim-em/lean-eval)),
- two Docker image variants — a slim core-Lean runner and a
  Mathlib-bundled runner — that the Codewars runner can invoke
  directly,
- a `judge` entrypoint that adapts Codewars' existing
  `Preloaded.lean` / `Solution.lean` / `SolutionTest.lean` file
  convention into a comparator workspace,
- worked examples and a written pitch
  ([`docs/proposal.md`](docs/proposal.md)) to send upstream.

The current Codewars Lean 3 corpus is authored against mathlib3, so
the Mathlib image is part of the launch (not deferred); see
[`docs/proposal.md`](docs/proposal.md) for the corpus-migration story.

## Quick start (development)

```bash
bash scripts/prepare-runner.sh         # slim: toolchain + tools, no mathlib
bash scripts/prepare-runner.sh mathlib # mathlib: same, plus mathlib4 cache
bash scripts/verify-installation.sh    # runs the example kata end-to-end
```

## Quick start (Docker)

```bash
# Slim image (core Lean only):
docker build -t codewars-lean4:slim    -f docker/Dockerfile.slim    .
docker run --rm --network=none \
  -v "$(pwd)/examples/codewars-shape:/workdir:ro" \
  codewars-lean4:slim

# Mathlib image (extends slim, adds mathlib4 v4.30.0):
docker build -t codewars-lean4:mathlib -f docker/Dockerfile.mathlib .
docker run --rm --network=none \
  -v "$(pwd)/examples/mathlib-shape:/workdir:ro" \
  codewars-lean4:mathlib
```

## Layout

```
versions.env              # All pins (SHAs)
lean-toolchain            # leanprover/lean4:v4.30.0
scripts/                  # prepare-runner + install-* scripts
runner/                   # judge entrypoint + adapter + templates
docker/Dockerfile.slim    # core-Lean runner image
docker/Dockerfile.mathlib # mathlib runner image (FROM slim)
examples/                 # example katas (both file conventions)
docs/                     # kata-format, trust-model, upstream proposal
```

## Trust model (one-paragraph version)

Codewars needs to trust: the Lean kernel, the toolchain build,
`comparator`, `lean4export`, `landrun`, and the kata author's
`Preloaded.lean` / `SolutionTest.lean` (the trusted statement of the
problem). They do *not* need to trust the submitter's
`Solution.lean` — comparator + landrun sandbox it.

See [`docs/trust-model.md`](docs/trust-model.md) for the long version.

## Status

Both images green in CI on a standard `ubuntu-24.04` runner —
PASS + FAIL paths on all three example katas. Measured sizes: slim
3.85 GB, mathlib 11.95 GB. The mathlib kata wall time (~50s on a
2-core GitHub runner) is currently the main concern vs. Codewars'
20s Lean budget; see [`docs/proposal.md`](docs/proposal.md) for the
discussion.
