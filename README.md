# germany_plate

Germany's licence plates for the [`plate_number`](../plate-core) library
(renamed `core_plate` in a later phase of the split): the country panel with the
flag SVG this package ships, the standard EU car spec with its inspection
sticker and state seal, and the advisory `GermanPlateValidator`.

The validator is demo-scoped. It checks format and the forbidden letter/number
combinations, and it checks the district code's shape only — not membership of
the real `Unterscheidungszeichen` list. See the class doc for why.

## Depends on

`plate_number` (by path), for `PlateSpec`, `PlateCountry` and `PlateValidator`.
Nothing else — not `iran_plate`, not `plate_keypad`.

## Use

```dart
import 'package:germany_plate/germany_plate.dart';

PlateCanvas(spec: GermanPlates.car, validator: const GermanPlateValidator());
```
