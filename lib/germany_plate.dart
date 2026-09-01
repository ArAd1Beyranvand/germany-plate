/// Germany's licence plates for the `core_plate` library.
///
/// A [PlateCountry], the standard EU car [PlateSpec] with its two round
/// stickers, and the advisory [GermanPlateValidator]. Nothing here knows about
/// any other country package.
///
/// ```dart
/// PlateCanvas(spec: GermanPlates.car, validator: const GermanPlateValidator())
/// ```
library;

/// The country panel — caption, colours, and the flag SVG this package ships.
export 'src/germany_country.dart';

/// The car plate spec, including the inspection sticker and state seal decals.
export 'src/germany_plates.dart';

/// The advisory validator: format plus the forbidden letter/number
/// combinations. Demo-scoped — see the class doc for what it does not check.
export 'src/german_plate_validator.dart';
