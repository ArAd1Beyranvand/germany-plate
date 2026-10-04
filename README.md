FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the people of Germany to view examples:

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

- [`plate_core`](https://pub.dev/packages/plate-core) - Paint license plates.
- [`plate_alphabet`](https://pub.dev/packages/plate-alphabet) - A library of alphabets for license plates.
- [`plate_keypad`](https://pub.dev/packages/plate-keypad) - A character picker for license plates.
- [`plate_number_holder`](https://pub.dev/packages/plate-number-holder) - A frame to hold license plate numbers.
- [`algeria_plate`](https://pub.dev/packages/algeria-plate) - Algeria's licence plates.
- [`bolivia_plate`](https://pub.dev/packages/bolivia-plate) - Bolivia's licence plates.
- [`colombia_plate`](https://pub.dev/packages/colombia-plate) - Colombia's licence plates.
- [`cuba_plate`](https://pub.dev/packages/cuba-plate) - Cuba's licence plates.
- [`india_plate`](https://pub.dev/packages/india-plate) - India's licence plates.
- [`indonesia_plate`](https://pub.dev/packages/indonesia-plate) - Indonesia's licence plates.
- [`iran_plate`](https://pub.dev/packages/iran-plate) - Iran's licence plates.
- [`iranshahr_plate`](https://pub.dev/packages/iranshahr-plate) - Iranshahr region's licence plates.
- [`lebanon_plate`](https://pub.dev/packages/lebanon-plate) - Lebanon's licence plates.
- [`malaysia_plate`](https://pub.dev/packages/malaysia-plate) - Malaysia's licence plates.
- [`mali_plate`](https://pub.dev/packages/mali-plate) - Mali's licence plates.
- [`niger_plate`](https://pub.dev/packages/niger-plate) - Niger's licence plates.
- [`palestine_plate`](https://pub.dev/packages/palestine-plate) - Palestine's licence plates.
- [`sudan_plate`](https://pub.dev/packages/sudan-plate) - Sudan's licence plates.
- [`tunisia_plate`](https://pub.dev/packages/tunisia-plate) - Tunisia's licence plates.
- [`venezuela_plate`](https://pub.dev/packages/venezuela-plate) - venezuela_ licence plates.
- [`yemen_plate`](https://pub.dev/packages/yemen-plate) - Yemen's licence plates.
