/// Germany's licence plates for the `core_plate` library.
///
/// A [PlateCountry], the EU car [PlateSpec]s with their two round stickers,
/// and the advisory [GermanPlateValidator]. Nothing here knows about any other
/// country package.
///
/// ```dart
/// PlateCanvas(spec: GermanPlates.car, validator: const GermanPlateValidator())
/// ```
///
/// [GermanPlates.car] is the common shape — a two-letter area code and a
/// one-letter, four-digit identifier. A plate is not one fixed shape, though:
/// the area code runs to three letters and the identifier to two, so
/// [GermanPlates.carFor] builds any of the shapes the law issues, and the
/// canvas gets shorter as the plate does.
///
/// ```dart
/// // CUX DP 150 — a three-letter area code, group c: the eight-character max.
/// GermanPlates.carFor(districtLetters: 3, group: GermanIdentifierGroup.c)
/// ```
library;

/// The country panel — caption, colours, and the flag SVG this package ships.
export 'src/germany_country.dart';

/// The area-code alphabet: A-Z plus the umlauts Ä, Ö and Ü.
export 'src/germany_alphabets.dart';

/// The five identifier shapes the law issues, which [GermanPlates.carFor]
/// takes and [GermanPlateValidator] checks against.
export 'src/germany_identifier_group.dart';

/// The car plate specs, including the inspection sticker and state seal decals.
export 'src/germany_plates.dart';

/// The advisory validator: format plus the forbidden letter/number
/// combinations. Demo-scoped — see the class doc for what it does not check.
export 'src/german_plate_validator.dart';
