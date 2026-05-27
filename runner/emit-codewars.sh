#!/usr/bin/env bash
# Translates comparator's exit code + log into Codewars-format result
# tokens. Mirrors the legacy Codewars runner protocol described at
# https://docs.codewars.com/authoring/guidelines/submission-tests/
#
# Usage: emit-codewars.sh <comparator_exit_code> <comparator_log_path>
set -euo pipefail

EXIT_CODE="$1"
LOG="$2"

# Filter for the user-visible details panel:
#   - drop the expected `Challenge.lean ... uses sorry` warning (Challenge
#     intentionally has `sorry` bodies; users would mistake this for their
#     own code having sorry)
#   - drop `Submission.lean` path noise so the user reads errors against
#     their own Solution.lean rather than the runner-generated wrapper
filter_log() {
    if [ -s "${LOG}" ]; then
        sed -e '/^warning: Challenge\.lean.*declaration uses `sorry`/d' "${LOG}"
    fi
}

filter_log

if [ "${EXIT_CODE}" = "0" ]; then
    echo "<PASSED::>Comparator accepted the solution."
    exit 0
fi

# Translate common failures into Codewars-level messages. Order matters:
# more specific patterns first.
summary=""
if grep -q "Illegal axiom detected: 'sorryAx'" "${LOG}"; then
    summary="Your solution still uses sorry (or admit). Replace every placeholder with a real proof."
elif grep -q "Illegal axiom detected: 'Lean.ofReduceBool'" "${LOG}" \
  || grep -q "Illegal axiom detected: 'Lean.ofReduceNat'" "${LOG}"; then
    summary="Your proof uses native_decide or another computational axiom that is not allowed for this kata."
elif grep -q "Illegal axiom detected:" "${LOG}"; then
    axiom="$(grep -m1 "Illegal axiom detected:" "${LOG}" \
        | sed -E "s/.*Illegal axiom detected: *'([^']+)'.*/\1/" \
        | head -c 80)"
    summary="Your proof depends on the axiom \`${axiom}\`, which is not in the permitted list (propext, Quot.sound, Classical.choice)."
elif grep -q "Unknown identifier .Submission\." "${LOG}"; then
    name="$(grep -m1 "Unknown identifier .Submission\." "${LOG}" \
        | sed -E "s/.*Unknown identifier .Submission\.([A-Za-z0-9_]+).*/\1/" \
        | head -c 80)"
    summary="The runner expected a theorem named \`${name}\` in your Solution.lean (it will be wrapped in \`namespace Submission\`). Make sure the name matches the spec exactly."
elif grep -q "unknown module prefix" "${LOG}"; then
    summary="The runner doesn't bundle Mathlib (or other external libraries). This image runs on core Lean 4 only."
elif grep -q -i "unknown constant" "${LOG}"; then
    const="$(grep -m1 -i "unknown constant" "${LOG}" \
        | sed -E "s/.*[Uu]nknown constant *\`?([A-Za-z0-9_.]+)\`?.*/\1/" \
        | head -c 80)"
    summary="\`${const}\` is not available. This kata runs on core Lean 4 only — no Mathlib."
elif grep -q "Not a definitional equality" "${LOG}"; then
    summary="Your proof tried \`rfl\` but the two sides are not definitionally equal. The function in Preloaded.lean has its own definition; you'll need induction or rewriting, not just \`rfl\`."
elif grep -q "Type mismatch" "${LOG}"; then
    line="$(grep -m1 "error: .*: Type mismatch" "${LOG}" | head -c 200)"
    summary="Type mismatch in your proof. ${line:-See the trace above.}"
elif grep -q -E "function expected at|unexpected token|expected '" "${LOG}"; then
    line="$(grep -m1 -E "error: " "${LOG}" | head -c 200)"
    summary="Syntax error in your Solution.lean. ${line:-See the trace above.}"
elif grep -q "does not match" "${LOG}"; then
    summary="Your proof's theorem statement does not match the kata's specification. Check that the type signature is unchanged."
elif grep -q "kernel rejected" "${LOG}"; then
    summary="The Lean kernel rejected your proof. See the trace above for details."
elif grep -q -E "^error: " "${LOG}"; then
    line="$(grep -m1 -E "^error: " "${LOG}" | head -c 200)"
    summary="${line}"
elif grep -q "uncaught exception" "${LOG}"; then
    summary="$(grep -m1 "uncaught exception" "${LOG}" | head -c 200)"
else
    summary="Comparator rejected the solution (exit ${EXIT_CODE}). See the trace above."
fi

echo "<FAILED::>${summary}"
