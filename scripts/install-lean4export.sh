#!/usr/bin/env bash
# Clones leanprover/lean4export at the pinned SHA and builds it.
# Installs the lean4export binary into ${CODEWARS_BIN_DIR}.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../versions.env
source "${REPO_ROOT}/versions.env"

export PATH="${HOME}/.elan/bin:${PATH}"

mkdir -p "${CODEWARS_TOOLS_DIR}" "${CODEWARS_BIN_DIR}"
SRC_DIR="${CODEWARS_TOOLS_DIR}/lean4export"

if [ ! -d "${SRC_DIR}/.git" ]; then
    echo ">>> Cloning lean4export @ ${LEAN4EXPORT_SHA}"
    git clone "${LEAN4EXPORT_REPO}" "${SRC_DIR}"
fi

cd "${SRC_DIR}"
git fetch --quiet origin
git checkout --quiet "${LEAN4EXPORT_SHA}"

echo ">>> Building lean4export"
lake build

BIN="${SRC_DIR}/.lake/build/bin/lean4export"
test -x "${BIN}" || { echo "FATAL: lean4export binary not found at ${BIN}" >&2; exit 1; }

ln -sf "${BIN}" "${CODEWARS_BIN_DIR}/lean4export"
echo ">>> lean4export installed: ${CODEWARS_BIN_DIR}/lean4export"
