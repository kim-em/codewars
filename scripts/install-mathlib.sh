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

# After cache get, ${CODEWARS_MATHLIB_DIR}/.lake/packages/ contains every
# transitive dep mathlib needs (aesop, batteries, Qq, proofwidgets,
# plausible, importGraph, LeanSearchClient, ...). The runtime workspace
# must declare path-deps for each of these so Lake doesn't try to
# re-clone them at submission time (when the container has no network).
LAKEFILE="${REPO_ROOT}/runner/workspace-template-mathlib/lakefile.toml"
{
    echo ""
    echo "# Path-deps for mathlib's transitive dependencies, appended at"
    echo "# install-mathlib.sh time so the runtime workspace builds with"
    echo "# --network=none. Order of these entries does not matter."
    for pkg_dir in "${CODEWARS_MATHLIB_DIR}/.lake/packages/"*; do
        [ -d "${pkg_dir}" ] || continue
        pkg_name="$(basename "${pkg_dir}")"
        echo ""
        echo "[[require]]"
        echo "name = \"${pkg_name}\""
        echo "path = \"${pkg_dir}\""
    done
} >> "${LAKEFILE}"

echo ">>> mathlib4 installed at ${CODEWARS_MATHLIB_DIR}"
echo ">>> Transitive packages registered in ${LAKEFILE}:"
ls -1 "${CODEWARS_MATHLIB_DIR}/.lake/packages/"
