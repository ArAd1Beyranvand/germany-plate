import 'package:flutter/widgets.dart';
import 'package:plate_number/plate_number.dart';

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
}
