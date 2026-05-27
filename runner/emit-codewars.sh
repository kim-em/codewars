#!/usr/bin/env bash
# Translates comparator's exit code + log into Codewars-format result
# tokens. Mirrors the legacy Codewars runner protocol described at
# https://docs.codewars.com/authoring/guidelines/submission-tests/
#
# Usage: emit-codewars.sh <comparator_exit_code> <comparator_log_path>
set -euo pipefail

EXIT_CODE="$1"
LOG="$2"

# Always stream the raw log so the user-visible "details" panel has
# context; codewars usually shows stdout/stderr together.
if [ -s "${LOG}" ]; then
    cat "${LOG}"
fi

if [ "${EXIT_CODE}" = "0" ]; then
    echo "<PASSED::>Comparator accepted the solution."
    exit 0
fi

# Extract the most informative line for the user-visible verdict.
# Order matters: scan for comparator's actual rejection reasons first,
# falling back to a generic kernel-level error, and finally to a
# placeholder if nothing matched. The `sorry` warning that Lean prints
# for Challenge.lean is *expected* and must be ignored — Challenge
# always has `sorry` by design.
summary=""
for pattern in \
    'Illegal axiom detected' \
    'does not match' \
    'kernel rejected' \
    'Solution does not solve' \
    'Type mismatch' \
    'uncaught exception' \
    'error:'; do
    line="$(grep -m1 -E "${pattern}" "${LOG}" \
        | grep -v -E "Challenge\.lean.*sorry" \
        | head -c 240 || true)"
    if [ -n "${line}" ]; then
        summary="${line}"
        break
    fi
done

if [ -z "${summary}" ]; then
    summary="Comparator rejected the solution (exit ${EXIT_CODE})."
fi
echo "<FAILED::>${summary}"
