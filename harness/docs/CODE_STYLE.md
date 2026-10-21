# Code Style

The setup skill fills the choices marked `{{...}}`; the defaults in
parentheses come from the reference project.

**Comments**
- {{COMMENT_RULE}} (default: no comments by default).
- Section dividers are allowed when a file has clearly distinct
  regions: `// ── Title ─...─`, exactly {{LINE_LENGTH}} characters
  wide, indented to match the surrounding code.

**Naming**
- {{NAMING_RULE}} (default: no abbreviations in identifiers:
  `panelSettings`, not `ps`).
- No single-letter names except loop counters (`i`, `j`) and axes
  (`x`, `y`, `z`).
- A class's name matches what it *is*, not what it was copied from.
  Before mirroring an existing class's shape, check that the reason
  for that shape applies to the new case.
- Keep each naming register consistent (for example enum members in
  full words, entrenched data-field abbreviations left alone, UI
  strings abbreviated for space). Record the project's registers
  here.

**Types**
- Prefer explicit types over `var`; use `var` only when
  `new TypeName(...)` is on the right-hand side.

**Constants**
- No magic numbers: a literal that encodes a design fact (sizes,
  chances, caps, delays) is a named `const` or `static readonly`,
  declared where its concept lives. Exempt: `0`, `1`, `-1` in their
  obvious roles and one-off local layout tuning. A literal used in
  more than one file must be a constant.
- Constants are PascalCase, never SCREAMING_SNAKE_CASE.

**Scope**
- No dead code: no unused overloads, fields, helpers or flags.
- Unify incidental duplication instead of keeping near-copies.

**Formatting**
- Maximum line length {{LINE_LENGTH}}.
- No trailing whitespace; every file ends with a newline, including
  `.meta` files.
- Match the surrounding code's comment density, naming and idiom.
