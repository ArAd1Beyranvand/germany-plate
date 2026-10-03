import 'package:flutter/widgets.dart';
import 'package:core_plate/core_plate.dart';

/// Germany's plate chrome.
class GermanyCountry {
  const GermanyCountry._();

  /// Germany, as it appears on a standard EU plate: a blue panel with a white
  /// "D" identifier beside the flag.
  static const PlateCountry germany = PlateCountry(
    code: 'de',
    captionLines: ['D'],
    panelColor: Color(0xFF003399),
    panelTextColor: Color(0xFFFFFFFF),
    flagAspectRatio: 5 / 3,
    flag: SvgPlateAsset(
      'assets/flags/Flag_of_Germany.svg',
      package: 'germany_plate',
    ),
  );

  /// Bundeswehr `Y` plate: flag only, no euroband. Aspect ratio 39×68mm.
  static const PlateCountry bundeswehr = PlateCountry(
    code: 'de-y',
    captionLines: [],
    panelColor: Color(0xFFFFFFFF),
    panelTextColor: Color(0xFF000000),
    flagAspectRatio: 39 / 68,
    flag: SvgPlateAsset(
      'assets/flags/Flag_of_Germany.svg',
      package: 'germany_plate',
    ),
  );
}
