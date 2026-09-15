import 'package:core_plate/core_plate.dart';

/// The alphabets a German plate's slots are drawn over.
///
/// Germany needs one alphabet the core library does not ship: the area code
/// admits the umlauts Ä, Ö and Ü (GÖ for Göttingen, WÜ for Würzburg, BÜS for
/// Büsingen), but not ẞ. The identifier block does not — an umlaut *there* is
/// the film industry's conventional marker for a deliberately fake plate — so
/// the identifier's letters stay on [PlateAlphabet.latinUppercase] and only the
/// area code gets this one.
class GermanAlphabets {
  const GermanAlphabets._();

  /// A-Z plus Ä, Ö, Ü: the letters an `Unterscheidungszeichen` may use.
  ///
  /// The umlauts sort after Z rather than beside their base vowels, because
  /// [PlateAlphabet.characters] order is picker order and a typist scanning for
  /// Ü is better served by finding the three of them together than by hunting
  /// for one three-quarters of the way through the Latin run.
  static const PlateAlphabet districtLetters = PlateAlphabet(
    id: 'de.district',
    characters: [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z',
      'Ä',
      'Ö',
      'Ü',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
