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

# `lake exe cache get` downloads pre-built .olean files; a follow-up
# `lake build` verifies the cache is complete. If a kata import fails
# at submission time because of a missing olean, that's a much worse
# experience than failing here.
echo ">>> Verifying mathlib build is complete"
lake build Mathlib

echo ">>> mathlib4 installed at ${CODEWARS_MATHLIB_DIR}"
