#!/usr/bin/env bash
# Clones Zouuup/landrun at the pinned SHA and builds the binary.
# Tagged releases through v0.1.15 are missing flags comparator needs
# (--ldd, --add-exec), so we MUST build from source.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=../versions.env
source "${REPO_ROOT}/versions.env"

if ! command -v go >/dev/null 2>&1; then
    echo "FATAL: 'go' is required to build landrun from source." >&2
    echo "Install golang-go (Debian/Ubuntu) or equivalent and re-run." >&2
    exit 1
fi

mkdir -p "${CODEWARS_TOOLS_DIR}" "${CODEWARS_BIN_DIR}"
SRC_DIR="${CODEWARS_TOOLS_DIR}/landrun"

if [ ! -d "${SRC_DIR}/.git" ]; then
    echo ">>> Cloning landrun @ ${LANDRUN_SHA}"
    git clone "${LANDRUN_REPO}" "${SRC_DIR}"
fi

cd "${SRC_DIR}"
git fetch --quiet origin
git checkout --quiet "${LANDRUN_SHA}"

echo ">>> Building landrun"
# Build into a stable path under the source dir so we can symlink.
mkdir -p "${SRC_DIR}/bin"
go build -o "${SRC_DIR}/bin/landrun" ./cmd/landrun

BIN="${SRC_DIR}/bin/landrun"
test -x "${BIN}" || { echo "FATAL: landrun binary not found at ${BIN}" >&2; exit 1; }

# Probe for the flags comparator needs. If any are missing we fail loud
# so a future landrun reshuffle doesn't silently break the runner.
echo ">>> Verifying landrun has required flags"
HELP="$("${BIN}" --help 2>&1 || true)"
for flag in --best-effort --ro --rw --rox --rwx --ldd --add-exec; do
    if ! grep -q -- "${flag}" <<<"${HELP}"; then
        echo "FATAL: landrun build is missing required flag '${flag}'." >&2
        echo "Pinned SHA ${LANDRUN_SHA} no longer satisfies the runner contract." >&2
        exit 1
    fi
done

ln -sf "${BIN}" "${CODEWARS_BIN_DIR}/landrun"
echo ">>> landrun installed: ${CODEWARS_BIN_DIR}/landrun"
