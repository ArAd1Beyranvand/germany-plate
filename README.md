FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

https://platexample.ir/#/discover/germany

# germany_plate

Germany's licence plates for [`plate_core`](https://pub.dev/packages/plate_core). Ships the country panel and flag SVG, the standard EU car spec with its inspection sticker and state seal, and the advisory `GermanPlateValidator`.

The validator is demo-scoped: it checks format and the forbidden letter/number
combinations, and it checks the district code's **shape only** (`^[A-ZÄÖÜ]{1,3}$`) -
not whether that district is a place. See the class doc for why.

## Depends on

`plate_core` (`^0.1.0`). Nothing else.

## Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:germany_plate/germany_plate.dart';

PlateCanvas(
  spec: GermanPlates.car,
  validator: const GermanPlateValidator(),
  autoValidate: true,             // frame goes red on an invalid plate
  onChooseCharacter: (a) async => null,
);
```

Type the forbidden `88` and the frame turns red - and then accepts the keystroke
anyway. Validation is advice, not a bouncer. The repo's `plate_gallery/` app shows
this plate alongside every one the other country packages draw.

## Contains

- `GermanyCountry.germany` - the panel, `Flag_of_Germany.svg`,
  `de_inspection_sticker.png`, `de_state_seal.png`.
- `GermanPlates.car`.
- `GermanPlateValidator`.

## Also available

From the mighty people of Iran to the people of Germany to view examples:

- [`plate_core`](https://pub.dev/packages/plate_core) - Paint license plates.
- [`plate_core_bloc`](https://pub.dev/packages/plate_core_bloc) - The optional bloc layer for `plate_core`.
- [`iran_plate`](https://pub.dev/packages/iran_plate) - Iran's plates.
- [`palestine_plate`](https://pub.dev/packages/palestine_plate) - Palestine's plates.
- [`yemen_plate`](https://pub.dev/packages/yemen_plate) - Yemen's plates.
- [`plate_keypad`](https://pub.dev/packages/plate_keypad) - A character picker for license plates.
