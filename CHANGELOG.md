## 0.1.0

- Extracted from `plate-core` (package `plate_number`) at commit `86a0999`,
  core version `0.1.0` (unreleased), as phase P8 of the library split. This is
  a plain move — no code was rewritten in the transfer.
- Contains Germany's plate data and rule: `GermanyCountry.germany`,
  `GermanPlates.car`, and `GermanPlateValidator`. Depends on `plate_number` by
  path and nothing else.
- Owns `assets/de_inspection_sticker.png`, `assets/de_state_seal.png` and
  `assets/flags/Flag_of_Germany.svg`. They moved out of core's bundle in the
  same commit as the `AssetImage` / `SvgPlateAsset` literals that name them, so
  there is no revision in which a literal points at a package that does not
  declare the file.
- **Product decision (PLAN.md §6.8): `docs/districts.json` was deleted, not
  wired in.** The ~150 real `Unterscheidungszeichen` it held were unused by any
  code or pubspec. The validator's district check stays the permissive
  `^[A-ZÄÖÜ]{1,3}$`, which is consistent with the demo scope its doc comment
  has always claimed; keeping a district list accurate is not a promise this
  package makes. A consumer who wants strict district validation composes their
  own `PlateValidator`.
