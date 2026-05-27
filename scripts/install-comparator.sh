#!/usr/bin/env bash
# Clones leanprover/comparator at the pinned SHA and builds it.
# Installs the comparator binary into ${CODEWARS_BIN_DIR}.
# Idempotent: re-running rebuilds in place but skips clone if present.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../versions.env
source "${REPO_ROOT}/versions.env"

export PATH="${HOME}/.elan/bin:${PATH}"

mkdir -p "${CODEWARS_TOOLS_DIR}" "${CODEWARS_BIN_DIR}"
SRC_DIR="${CODEWARS_TOOLS_DIR}/comparator"

if [ ! -d "${SRC_DIR}/.git" ]; then
    echo ">>> Cloning comparator @ ${COMPARATOR_SHA}"
    git clone "${COMPARATOR_REPO}" "${SRC_DIR}"
fi

cd "${SRC_DIR}"
git fetch --quiet origin
git checkout --quiet "${COMPARATOR_SHA}"

# Do NOT `lake update`; it would overwrite lean-toolchain.
echo ">>> Building comparator"
lake build

BIN="${SRC_DIR}/.lake/build/bin/comparator"
test -x "${BIN}" || { echo "FATAL: comparator binary not found at ${BIN}" >&2; exit 1; }

ln -sf "${BIN}" "${CODEWARS_BIN_DIR}/comparator"
echo ">>> comparator installed: ${CODEWARS_BIN_DIR}/comparator"
