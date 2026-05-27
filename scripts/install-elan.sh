#!/usr/bin/env bash
# Installs elan (Lean version manager) and the toolchain pinned in
# lean-toolchain. Idempotent: re-running is a no-op if elan is already
# installed and the toolchain is already resolved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../versions.env
source "${REPO_ROOT}/versions.env"

if ! command -v elan >/dev/null 2>&1; then
    echo ">>> Installing elan"
    curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
        | sh -s -- -y --default-toolchain none
    # shellcheck disable=SC1090
    source "${HOME}/.elan/env"
else
    echo ">>> elan already installed: $(elan --version)"
fi

# Make elan binaries discoverable in this shell.
export PATH="${HOME}/.elan/bin:${PATH}"

echo ">>> Installing Lean toolchain ${LEAN_VERSION}"
# `elan toolchain install` is idempotent. We deliberately do NOT call
# `elan default` — every codewars workspace ships its own lean-toolchain
# file, and changing the global default could surprise other users of
# the same machine during development.
elan toolchain install "leanprover/lean4:${LEAN_VERSION}"

echo ">>> Lean toolchain ready: $(elan run "leanprover/lean4:${LEAN_VERSION}" lean --version)"
