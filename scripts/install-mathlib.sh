#!/usr/bin/env bash
# Clones mathlib4 at the pinned SHA and pre-fetches its olean cache.
# Used only by the mathlib image variant. The slim image does not call
# this script.
#
# After this runs, ${CODEWARS_MATHLIB_DIR} contains a complete mathlib
# checkout with .lake/build/lib/ populated. Workspaces use it via a
# path-dep — no network needed at submission time.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../versions.env
source "${REPO_ROOT}/versions.env"

export PATH="${HOME}/.elan/bin:${PATH}"

if [ ! -d "${CODEWARS_MATHLIB_DIR}/.git" ]; then
    echo ">>> Cloning mathlib4 @ ${MATHLIB_SHA}"
    git clone "${MATHLIB_REPO}" "${CODEWARS_MATHLIB_DIR}"
fi

cd "${CODEWARS_MATHLIB_DIR}"
git fetch --quiet origin
git checkout --quiet "${MATHLIB_SHA}"

echo ">>> Fetching mathlib olean cache (large download, several GB)"
lake exe cache get

# lake exe cache get extracts files with restrictive modes (read-only
# directories in particular) that block Lake's hash-file writes at
# kata submission time. Add owner read/write to every file and rwx to
# every directory under .lake so Lake can both traverse and create.
find "${CODEWARS_MATHLIB_DIR}/.lake" -type d -exec chmod u+rwx {} +
find "${CODEWARS_MATHLIB_DIR}/.lake" -type f -exec chmod u+rw  {} +

# `lake exe cache get` ships oleans + ileans but NOT the .hash trace
# files Lake's incremental-build replay expects. Running `lake build`
# here materialises every .hash file using the cached oleans, so kata
# submissions can replay traces read-only without trying to write
# back into /opt/codewars/mathlib. Fast because all oleans are cached
# already — Lake just hashes the inputs and writes the trace markers.
echo ">>> Materialising mathlib hash trace files (lake build w/ cached oleans)"
lake build Mathlib

# Build a skeleton workspace that mirrors the runtime kata workspace,
# resolve its dependencies, and BUILD workspace_test ONCE here (with
# network). This:
#   - generates lake-manifest.json pinning every transitive dep at
#     the SHA mathlib itself pins (so kata submissions never run the
#     post-update hook),
#   - runs proofwidgets' widget npm install + bundle (so kata
#     submissions don't try to replay it offline),
#   - leaves .lake/packages and .lake/build in a clean state that
#     submissions hardlink-copy at runtime.
SKELETON="${CODEWARS_PREFIX}/mathlib-skeleton"
echo ">>> Building mathlib workspace skeleton at ${SKELETON}"
mkdir -p "${SKELETON}"
cd "${SKELETON}"

# The skeleton's lakefile is exactly the runtime workspace template
# (so its manifest is valid for the runtime workspace too).
cp "${REPO_ROOT}/runner/workspace-template-mathlib/lakefile.toml" lakefile.toml
cp "${REPO_ROOT}/runner/workspace-template/lean-toolchain"        lean-toolchain
cp "${REPO_ROOT}/runner/workspace-template/WorkspaceTest.lean"    WorkspaceTest.lean
# Empty stubs so lean_lib targets resolve. Will be overwritten by the
# adapter at submission time.
: > ChallengeDeps.lean
: > Challenge.lean
: > Solution.lean
: > Submission.lean

# Network access here. Resolves transitive deps, triggers post-update.
lake update

# Builds workspace_test (trusted exe importing only Lean) plus the
# transitive build steps it needs — including proofwidgets/widget's
# npm install. Bounded build time even on a free runner because
# mathlib's oleans are already cached.
lake build workspace_test

echo ">>> Skeleton populated:"
ls -1 "${SKELETON}/.lake/packages/" 2>/dev/null || echo "(none)"
test -f "${SKELETON}/lake-manifest.json" || { echo "FATAL: skeleton manifest not generated" >&2; exit 1; }

echo ">>> mathlib4 installed at ${CODEWARS_MATHLIB_DIR}"
