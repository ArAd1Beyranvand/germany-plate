/// Germany's licence plates for the `plate_core` library.
///
/// A [PlateCountry], the EU car [PlateSpec]s with their two round stickers,
/// and the advisory [GermanPlateValidator].
library;

// TODO(py): [D5] one module `plates.countries.germany`; assets via importlib.resources.
// TODO(ts): [D5] one subpath export `./countries/germany`; tree-shakable.
// TODO(kt): [D5] package `countries.germany` in the countries module.
export 'src/german_plate_validator.dart';
export 'src/germany_alphabets.dart';
export 'src/germany_country.dart';
export 'src/germany_identifier_group.dart';
export 'src/germany_plates.dart';
export 'src/germany_regions.dart';
