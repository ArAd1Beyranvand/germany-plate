FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the thoughtful people of Germany to view examples:

https://platexample.ir/#/discover/germany

# germany_plate

Germany's licence plates for the `plate_core` library. A `PlateCountry`, the EU car `PlateSpec`s with their two round stickers, and the advisory `GermanPlateValidator`.

## Install

```yaml
dependencies:
  plate_core: ^0.12.0
  germany_plate: ^0.2.0
```

## Use

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

## Contains

- `GermanyCountry` — country panels: `germany`, `bundeswehr`.
- `GermanPlates` — 11 plate specs: `car`, `carFor()`, `greenFor()`, `historicFor()`, `electricFor()`, `seasonalFor()`, `dealerFor()`, `collectorFor()`, `shortTermFor()`, `exportFor()`, `bundeswehrFor()`.
- `GermanPlateValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `GermanSerialPlateValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `GermanDatedPlateValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `GermanBundeswehrValidator` — advisory validator; flags the frame, never blocks a keystroke.
- `GermanyRegions` — code table.
- 2 bundled assets (`de_inspection_sticker.png`, `de_state_seal.png`).

## Part of plate

Painted by [`plate_core`](https://pub.dev/packages/plate_core); alphabets shared through [`plate_alphabet`](https://pub.dev/packages/plate_alphabet); optional character picker in [`plate_keypad`](https://pub.dev/packages/plate_keypad).

