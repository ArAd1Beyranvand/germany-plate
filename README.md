# germany_plate

Germany's licence plates for the [`core_plate`](../core-plate) library: the
country panel with the flag SVG this package ships, the standard EU car spec with
its inspection sticker and state seal, and the advisory `GermanPlateValidator`.

The validator is demo-scoped. It checks format and the forbidden letter/number
combinations, and it checks the district code's **shape only** (`^[A-ZÄÖÜ]{1,3}$`)
— not membership of the real `Unterscheidungszeichen` list. See the class doc for
why, and `core-plate/docs/split/PLAN.md` §6.8 for the decision.

## Depends on

`core_plate` (by path, `../core-plate`), for `PlateSpec`, `PlateCountry` and
`PlateValidator`.

## Does not depend on

`iran_plate`, `plate_keypad`, or anything else.

## Use

```dart
import 'package:core_plate/core_plate.dart';
import 'package:germany_plate/germany_plate.dart';

PlateCanvas(
  spec: GermanPlates.car,
  validator: const GermanPlateValidator(),
  autoValidate: true,             // paints the frame red on an invalid plate;
  onChooseCharacter: (a) async => null,
);
```

`autoValidate: true` paints the frame red when the plate is invalid — for
example the forbidden `88` — and **still accepts the keystroke**. Validation is
advisory; it never blocks input.

## Contains

- `GermanyCountry.germany` — the country panel, `Flag_of_Germany.svg`,
  `de_inspection_sticker.png`, `de_state_seal.png`.
- `GermanPlates.car`.
- `GermanPlateValidator`.
