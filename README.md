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

This is an **MVP**. Mathlib support is explicitly phase 2; the slim
image targets pure-Lean theorem-proving katas only.

## Quick start (development)

```bash
bash scripts/prepare-runner.sh         # installs toolchain + tools
bash scripts/verify-installation.sh    # runs the example kata end-to-end
```

## Quick start (Docker)

```bash
docker build -t codewars-lean4:slim -f docker/Dockerfile .
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
docker/Dockerfile         # slim runner image
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

Work in progress. Tracking the writeup in
[`docs/proposal.md`](docs/proposal.md).
