/// Germany's licence plates for the `core_plate` library.
///
/// A [PlateCountry], the EU car [PlateSpec]s with their two round stickers,
/// and the advisory [GermanPlateValidator]. Nothing here knows about any other
/// country package.
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

/// The advisory validators: [GermanPlateValidator] for registrations — format,
/// the season block, and the forbidden letter/number combinations —
/// [GermanSerialPlateValidator] for the `06` and `07` numbers,
/// [GermanDatedPlateValidator] for the `04` short-term and export numbers with
/// their expiry date, and [GermanBundeswehrValidator] for the military `Y`
/// number. Only the first judges a registration; the rest follow none of its
/// rules. [GermanPlates.validatorFor] picks between them. Demo-scoped; see the
/// class docs for what they do not check.
export 'src/german_plate_validator.dart';
