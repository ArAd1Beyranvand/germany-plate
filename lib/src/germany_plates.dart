import 'package:flutter/widgets.dart';
import 'package:core_plate/core_plate.dart';

import 'germany_country.dart';

/// The German plate designs.
class GermanPlates {
  const GermanPlates._();

  /// A standard German car plate (e.g. "DA·X1953"): a district code of Latin
  /// letters, then the two round stickers (vehicle-inspection and federal-state
  /// seal), then the identifier's Latin letter and serial digits — read
  /// left-to-right, with no dividers and no printed labels. The stickers are
  /// [PlateDecal]s that sit in the gap between the two character groups.
  static const PlateSpec car = PlateSpec(
    id: 'de.car',
    country: GermanyCountry.germany,
    canvasWidth: 520,
    canvasHeight: 110,
    panel: PlatePanel(
      // Overlap the border on the three touching edges — see IranPlates.car.
      box: PlateBox(0, 0, 56.4, 110),
    ),
    textDirection: TextDirection.ltr,
    slots: [
      // District code, e.g. "DA".
      PlateSlot(
        alphabet: PlateAlphabet.latinUppercase,
        box: PlateBox(64, 17, 52, 76),
      ),
      PlateSlot(
        alphabet: PlateAlphabet.latinUppercase,
        box: PlateBox(122, 17, 52, 76),
      ),
      // Identifier: one letter then the serial digits, e.g. "X1953".
      PlateSlot(
        alphabet: PlateAlphabet.latinUppercase,
        box: PlateBox(230, 17, 52, 76),
      ),
      PlateSlot(
        alphabet: PlateAlphabet.latinDigits,
        box: PlateBox(288, 17, 46, 76),
      ),
      PlateSlot(
        alphabet: PlateAlphabet.latinDigits,
        box: PlateBox(338, 17, 46, 76),
      ),
      PlateSlot(
        alphabet: PlateAlphabet.latinDigits,
        box: PlateBox(388, 17, 46, 76),
      ),
      PlateSlot(
        alphabet: PlateAlphabet.latinDigits,
        box: PlateBox(438, 17, 46, 76),
      ),
    ],
    decals: [
      // Stacked in the gap between the district code and the identifier: the
      // orange TÜV inspection sticker on top, the federal-state seal below.
      PlateDecal(
        image: AssetImage(
          'assets/de_inspection_sticker.png',
          package: 'germany_plate',
        ),
        box: PlateBox(184, 14, 38, 38),
      ),
      PlateDecal(
        image: AssetImage('assets/de_state_seal.png', package: 'germany_plate'),
        box: PlateBox(184, 54, 38, 38),
      ),
    ],
    textGroups: [
      PlateTextGroup([0, 1], key: 'district'),
      PlateTextGroup([2], key: 'letters'),
      PlateTextGroup([3, 4, 5, 6], key: 'serial'),
    ],
  );
}
