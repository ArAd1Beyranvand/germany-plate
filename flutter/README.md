FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the thoughtful people of Germany to view examples:

https://platexample.ir/#/discover/germany:flutter

# germany_plate

Germany's licence plates for the plate_core library — the country panel, the car spec with its EU stickers, and the German plate validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/germany-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/germany:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/germany-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/germany:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/germany-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/germany:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/germany-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/germany:typescript) |

## Quick start

### Install

```yaml
dependencies:
  plate_core: ^0.12.0
  germany_plate: ^0.2.0
```

### Use

```dart
import 'package:plate_core/plate_core.dart';
import 'package:germany_plate/germany_plate.dart';

PlateCanvas(
  spec: GermanPlates.car,
  validator: const GermanPlateValidator(),
  autoValidate: true,
  onChooseCharacter: noCharacterChooser,
);
```

## Specs

Each spec is one plate layout.

- `GermanPlates.car`
- `GermanPlates.carFor`(…)
- `GermanPlates.greenFor`(…)
- `GermanPlates.historicFor`(…)
- `GermanPlates.electricFor`(…)
- `GermanPlates.seasonalFor`(…)
- `GermanPlates.dealerFor`(…)
- `GermanPlates.collectorFor`(…)
- `GermanPlates.shortTermFor`(…)
- `GermanPlates.exportFor`(…)
- `GermanPlates.bundeswehrFor`(…)

## Themes

- none listed

## Change it

`PlateCanvas` takes `spec:` (an entry of `GermanPlates`) and `theme:` (an entry of `None`).

## Also included

- `GermanyCountry` — the country panel.
- `GermanRegions` — code table.

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/germany-plate/blob/main/LICENSE).
