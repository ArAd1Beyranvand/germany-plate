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
    flag: SvgPlateAsset('assets/flags/Flag_of_Germany.svg', package: 'germany_plate'),
  );

  /// Germany as it appears on a Bundeswehr `Y` plate: the flag alone, printed
  /// straight onto the white face, with no blue block and no country code.
  ///
  /// A military plate is not an EU registration — it carries no euroband — so
  /// the "panel" here is a white block that paints nothing but the flag. It is
  /// a second [PlateCountry] rather than a render-time override of
  /// [germany], because the block it describes is a different *shape* as well
  /// as a different colour, and a shape is spec geometry.
  ///
  /// [flagAspectRatio] is the block the Bundeswehr prints, not the 5:3 of the
  /// national flag: on a real `Y` plate the black-red-gold is a tall panel
  /// roughly 39mm by 68mm. The stripes are horizontal, so the taller ratio
  /// reads as a taller flag rather than as a distorted one.
  static const PlateCountry bundeswehr = PlateCountry(
    // Not an ISO code: there is no country here to collide with, and this is
    // the equality and persistence key for Germany's military chrome.
    code: 'de-y',
    captionLines: [],
    panelColor: Color(0xFFFFFFFF),
    panelTextColor: Color(0xFF000000),
    flagAspectRatio: 39 / 68,
    flag: SvgPlateAsset('assets/flags/Flag_of_Germany.svg', package: 'germany_plate'),
  );
}
