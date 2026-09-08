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
  /// `final`, not `const`: the serial is built by [plateRegister], and a `const`
  /// constructor cannot run a loop. Initialised lazily, once per isolate, and
  /// [PlateSpec] equality is over `id` alone — nothing here depended on const
  /// canonicalisation.
  static final PlateSpec car = PlateSpec(
    id: 'de.car',
    country: GermanyCountry.germany,
    canvasWidth: 520,
    canvasHeight: 110,
    panel: const PlatePanel(
      // Overlap the border on the three touching edges — see IranPlates.car.
      box: PlateBox(0, 0, 56.4, 110),
    ),
    textDirection: TextDirection.ltr,
    slots: [
      // District code, e.g. "DA". Two cells is not a register worth naming.
      const PlateSlot(
        alphabet: PlateAlphabet.latinUppercase,
        box: PlateBox(64, 17, 52, 76),
      ),
      const PlateSlot(
        alphabet: PlateAlphabet.latinUppercase,
        box: PlateBox(122, 17, 52, 76),
      ),
      // Identifier: one letter, then the serial digits, e.g. "X1953". The
      // letter is wider than a digit and sits on its own pitch, so it stays a
      // literal; the four digits are one register at pitch 50.
      const PlateSlot(
        alphabet: PlateAlphabet.latinUppercase,
        box: PlateBox(230, 17, 52, 76),
      ),
      ...plateRegister(
        alphabet: PlateAlphabet.latinDigits,
        count: 4,
        left: 288,
        top: 17,
        width: 46,
        height: 76,
        pitch: 50,
      ),
    ],
    decals: const [
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
    textGroups: const [
      PlateTextGroup([0, 1], key: 'district'),
      PlateTextGroup([2], key: 'letters'),
      PlateTextGroup([3, 4, 5, 6], key: 'serial'),
    ],
  );
}
