import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

/// Germany's plate chrome.
class GermanyCountry {
  static const PlateDrawing _flag = PlateDrawing(5, 3, <PlateShape>[
    PlateRectShape(0, 0, 5, 3, Color(0xFF000000)),
    PlateRectShape(0, 1, 5, 2, Color(0xFFDD0000)),
    PlateRectShape(0, 2, 5, 1, Color(0xFFFFCE00)),
  ]);

  const GermanyCountry._();

  /// Germany, as it appears on a standard EU plate: a blue panel with a white
  /// "D" identifier beside the flag.
  static const PlateCountry germany = PlateCountry(
    code: 'de',
    captionLines: ['D'],
    panelColor: Color(0xFF003399),
    panelTextColor: Color(0xFFFFFFFF),
    flagAspectRatio: 5 / 3,
    flag: _flag,
  );

  /// Bundeswehr `Y` plate: flag only, no euroband. Aspect ratio 39×68mm.
  static const PlateCountry bundeswehr = PlateCountry(
    code: 'de-y',
    captionLines: [],
    panelColor: Color(0xFFFFFFFF),
    panelTextColor: Color(0xFF000000),
    flagAspectRatio: 39 / 68,
    flag: _flag,
  );
}
