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
- a slim Docker image that the Codewars runner can invoke directly,
- a `judge` entrypoint that adapts Codewars' existing
  `Preloaded.lean` / `Solution.lean` / `SolutionTest.lean` file
  convention into a comparator workspace,
- worked examples and a written pitch
  ([`docs/proposal.md`](docs/proposal.md)) to send upstream.

A Mathlib-bundled image was prototyped and then dropped. Per-kata
wall time for `import Mathlib` was ~50s on a standard CI runner —
well over Codewars' 20s Lean budget and past the slowest documented
language on the platform (Scala at 27s). The corpus-migration story
is documented in [`docs/proposal.md`](docs/proposal.md) as future
work; Lean 4 katas at launch target core Lean only.

## Quick start (development)

```bash
bash scripts/prepare-runner.sh         # installs toolchain + tools
bash scripts/verify-installation.sh    # runs the example kata end-to-end
```

## Quick start (Docker)

```bash
docker build -t codewars-lean4:slim -f docker/Dockerfile.slim .
docker run --rm --network=none \
  -v "$(pwd)/examples/codewars-shape:/workdir:ro" \
  codewars-lean4:slim
```

## Layout

```
versions.env              # All pins (SHAs)
lean-toolchain            # leanprover/lean4:v4.30.0
scripts/                  # prepare-runner + install-* scripts
runner/                   # judge entrypoint + adapter + templates
docker/Dockerfile.slim    # runner image
examples/                 # example katas (both file conventions)
starter-katas/            # ten launch katas (7–4 kyu), CI-verified
docs/                     # kata-format, solver-guide, trust-model, proposal
```

## Trust model (one-paragraph version)

Codewars needs to trust: the Lean kernel, the toolchain build,
`comparator`, `lean4export`, `landrun`, and the kata author's
`Preloaded.lean` / `SolutionTest.lean` (the trusted statement of the
problem). They do *not* need to trust the submitter's
`Solution.lean` — comparator + landrun sandbox it.

See [`docs/trust-model.md`](docs/trust-model.md) for the long version.

## Status

Slim image green in CI on a standard `ubuntu-24.04` runner — both
example katas PASS, sorry-submission negative test FAILs as expected.
Measured size 3.85 GB; per-kata wall time ~3s (well inside Codewars'
20s budget). Ready to draft a runner-side PR / discussion with
Codewars maintainers.
