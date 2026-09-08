## Unreleased

- **The serial is a register, not four rectangles.** `GermanPlates.car`'s four
  digits are built by `plateRegister` (core 0.6.0) — one call stating x 288,
  pitch 50 — rather than four hand-written `PlateBox` literals. The geometry is
  unchanged to the unit; nothing on a rendered plate moves.
- The two district letters and the identifier letter stay literal. Two cells is
  not a register worth naming, and the identifier letter sits on its own pitch.
- `GermanPlates.car` is now `static final` rather than `static const`: a `const`
  constructor cannot run a loop. `PlateSpec` equality is over `id` alone and a
  `static final` is initialised lazily once per isolate, so this changes no
  behaviour — but `const spec = GermanPlates.car;` must become `final spec = …`,
  as the example now does.
- Requires `core_plate: ^0.6.0` for `plateRegister`.

## 0.1.0

First pub.dev release.

- Depends on the published `core_plate: ^0.1.0` (was a sibling `path:`
  dependency). The import is `package:core_plate/core_plate.dart`. No API of
  `germany_plate` changed.

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
