#!/usr/bin/env python3
"""Adapter: translates the Codewars Lean 4 file convention into a
comparator workspace.

Codewars file shape (input):
  Preloaded.lean      trusted; imports + helper definitions
  Solution.lean       user-submitted; the proof bodies
  SolutionTest.lean   trusted; theorem statements

The author writes SolutionTest.lean as a sequence of top-level
theorems whose bodies refer to a `Submission` namespace, e.g.:

    import ChallengeDeps

    theorem two_plus_two : (2 : Nat) + 2 = 4 := Submission.two_plus_two

    theorem associativity (a b c : Nat) : (a + b) + c = a + (b + c) :=
      Submission.associativity a b c

This script:
  - copies Preloaded.lean to ChallengeDeps.lean,
  - copies SolutionTest.lean verbatim to Solution.lean (the comparator
    "Solution" file: bridges to Submission.<name>),
  - generates Challenge.lean by stripping each theorem body and
    replacing it with `by sorry`,
  - wraps the user's Solution.lean in `namespace Submission` to produce
    Submission.lean,
  - extracts theorem names and writes config.json.

The parse is regex-based and intentionally restrictive — kata authors
must keep top-level theorems on lines beginning with `theorem` (no
leading indentation, no `protected`/`private`/`@[…]`). This is
documented in docs/kata-format.md.
"""

from __future__ import annotations

import json
import re
import shutil
import sys
from pathlib import Path

THEOREM_HEAD = re.compile(r"^theorem\s+([A-Za-z_][A-Za-z0-9_]*)", re.MULTILINE)
# A "top-level item" line marks where a theorem's body ends. We treat the
# body as everything between `:=` (on the theorem header line, possibly
# after a wrap) and the next line that starts one of these keywords or
# end-of-file.
BODY_TERMINATOR = re.compile(
    r"^(theorem|def|example|instance|abbrev|class|structure|inductive|section|end|namespace)\b",
    re.MULTILINE,
)


def fail(msg: str) -> "_NoReturn":
    print(f"<ERROR::>{msg}", file=sys.stderr)
    sys.exit(2)


_NoReturn = type(None)  # only used for typing


def parse_theorems(source: str) -> list[tuple[str, int, int]]:
    """Return [(name, start_offset_of_body, end_offset_of_body), ...]
    where the body is the text after `:=` and before the next top-level
    item. Both offsets are into `source`.
    """
    items: list[tuple[str, int, int]] = []
    for head in THEOREM_HEAD.finditer(source):
        name = head.group(1)
        # Find the `:=` that delimits header from body for THIS theorem.
        # Scan forward from the theorem head; `:=` may be on a later line.
        i = source.find(":=", head.end())
        if i < 0:
            fail(f"theorem '{name}' in SolutionTest.lean has no ':=' body")
        body_start = i + len(":=")
        # Body ends at the next top-level keyword or EOF.
        m = BODY_TERMINATOR.search(source, body_start + 1)
        body_end = m.start() if m else len(source)
        items.append((name, body_start, body_end))
    return items


def build_challenge(solution_test: str, theorems: list[tuple[str, int, int]]) -> str:
    """Replace each theorem body with ` by sorry`."""
    out: list[str] = []
    cursor = 0
    for _name, body_start, body_end in theorems:
        out.append(solution_test[cursor:body_start])
        out.append(" by sorry\n")
        cursor = body_end
        # Trim a trailing newline if we just inserted one (avoids double blanks).
        if cursor < len(solution_test) and solution_test[cursor] == "\n":
            cursor += 1
    out.append(solution_test[cursor:])
    return "".join(out)


def main() -> None:
    if len(sys.argv) != 3:
        fail("usage: adapter.py <indir> <outdir>")
    indir = Path(sys.argv[1]).resolve()
    outdir = Path(sys.argv[2]).resolve()

    preloaded = indir / "Preloaded.lean"
    solution_user = indir / "Solution.lean"
    solution_test = indir / "SolutionTest.lean"
    for p in (preloaded, solution_user, solution_test):
        if not p.is_file():
            fail(f"required Codewars file missing: {p.name}")

    outdir.mkdir(parents=True, exist_ok=True)

    # Workspace template (lakefile.toml, lean-toolchain, WorkspaceTest.lean,
    # config.json.tmpl). Copy everything in workspace-template/ to outdir.
    template_dir = Path(__file__).resolve().parent / "workspace-template"
    for p in template_dir.iterdir():
        if p.name == "config.json.tmpl":
            continue  # rendered below
        shutil.copy2(p, outdir / p.name)

    # ChallengeDeps.lean from Preloaded.lean.
    shutil.copy2(preloaded, outdir / "ChallengeDeps.lean")

    # Solution.lean (the comparator-side delegating file): SolutionTest.lean
    # plus an injected `import Submission` so the `Submission.<name>` bodies
    # in the spec can resolve.
    spec_text = solution_test.read_text()
    (outdir / "Solution.lean").write_text("import Submission\n" + spec_text)

    # Challenge.lean = spec with theorem bodies replaced by `by sorry`.
    # Challenge does NOT import Submission — its bodies don't reference it.
    theorems = parse_theorems(spec_text)
    if not theorems:
        fail("SolutionTest.lean contains no top-level `theorem` declarations")
    challenge_text = build_challenge(spec_text, theorems)
    (outdir / "Challenge.lean").write_text(challenge_text)

    # Submission.lean = user's Solution.lean wrapped in `namespace Submission`.
    user_body = solution_user.read_text()
    submission_text = (
        "import ChallengeDeps\n"
        "\n"
        "namespace Submission\n"
        "\n"
        + user_body
        + ("\n" if not user_body.endswith("\n") else "")
        + "\n"
        "end Submission\n"
    )
    (outdir / "Submission.lean").write_text(submission_text)

    # config.json with theorem names.
    template = (template_dir / "config.json.tmpl").read_text()
    names_json = json.dumps([name for name, _, _ in theorems])
    (outdir / "config.json").write_text(template.replace("__THEOREM_NAMES__", names_json))


if __name__ == "__main__":
    main()
