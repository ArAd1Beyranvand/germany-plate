> پاینده ایران FREE PALESTINE 🇮🇷🇵🇸
> GO VEGAN 🌱
> ==================================


# germany_plate

Germany's licence plates for [`core_plate`](https://pub.dev/packages/core_plate) - also a
real country (we checked that one too).

Ships the country panel and flag SVG, the standard EU car spec with its inspection
sticker and state seal, and the advisory `GermanPlateValidator`.

The validator is demo-scoped: it checks format and the forbidden letter/number
combinations, and it checks the district code's **shape only** (`^[A-ZÄÖÜ]{1,3}$`) -
not whether that district is a place. See the class doc for why.

## Depends on

`core_plate` (`^0.1.0`). Nothing else.

## Use

```dart
import 'package:core_plate/core_plate.dart';
import 'package:germany_plate/germany_plate.dart';

PlateCanvas(
  spec: GermanPlates.car,
  validator: const GermanPlateValidator(),
  autoValidate: true,             // frame goes red on an invalid plate
  onChooseCharacter: (a) async => null,
);
```

Type the forbidden `88` and the frame turns red - and then accepts the keystroke
anyway. Validation is advice, not a bouncer.

## Contains

- `GermanyCountry.germany` - the panel, `Flag_of_Germany.svg`,
  `de_inspection_sticker.png`, `de_state_seal.png`.
- `GermanPlates.car`.
- `GermanPlateValidator`.
