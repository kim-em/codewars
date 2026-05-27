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

# Build a skeleton workspace and resolve its dependencies ONCE here
# (with network). Mathlib's post-update hook runs as part of `lake
# update`, generating a lake-manifest.json that pins every transitive
# dep at the SHA mathlib itself pins. We then reuse the skeleton's
# manifest + .lake/packages/ for every kata submission, so submissions
# build with --network=none and don't trigger the post-update hook.
SKELETON="${CODEWARS_PREFIX}/mathlib-skeleton"
echo ">>> Building mathlib workspace skeleton at ${SKELETON}"
mkdir -p "${SKELETON}"
cd "${SKELETON}"

cat > lakefile.toml <<EOF
name = "mathlib-skeleton"

[[require]]
name = "mathlib"
path = "${CODEWARS_MATHLIB_DIR}"
EOF

cp "${REPO_ROOT}/runner/workspace-template/lean-toolchain" lean-toolchain

# Triggers cloning of mathlib's transitive deps into .lake/packages/
# and writes a lake-manifest.json. Network required here; never again.
lake update

echo ">>> Skeleton populated:"
ls -1 "${SKELETON}/.lake/packages/" 2>/dev/null || echo "(none)"
test -f "${SKELETON}/lake-manifest.json" || { echo "FATAL: skeleton manifest not generated" >&2; exit 1; }

echo ">>> mathlib4 installed at ${CODEWARS_MATHLIB_DIR}"
