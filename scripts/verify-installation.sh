#!/usr/bin/env bash
# End-to-end check that the runner accepts examples/comparator-direct.
# Exits 0 on accept, 1 on reject, 2 on infra error.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../versions.env
source "${REPO_ROOT}/versions.env"

# Make installed binaries discoverable.
export PATH="${CODEWARS_BIN_DIR}:${HOME}/.elan/bin:${HOME}/.local/bin:${PATH}"

echo ">>> Tool versions"
for tool in lean lake comparator landrun lean4export; do
    if command -v "${tool}" >/dev/null 2>&1; then
        printf "  %-12s %s\n" "${tool}" "$(command -v "${tool}")"
    else
        echo "  ${tool}: MISSING" >&2
        exit 2
    fi
done

EXAMPLE_DIR="${REPO_ROOT}/examples/comparator-direct"
if [ ! -d "${EXAMPLE_DIR}" ]; then
    echo "FATAL: example kata not found at ${EXAMPLE_DIR}" >&2
    exit 2
fi

echo ""
echo ">>> Running comparator-direct example kata"
"${REPO_ROOT}/runner/judge" --mode comparator-direct "${EXAMPLE_DIR}"
