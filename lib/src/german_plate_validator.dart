/// Validates the identifier letter block of a German (Kennzeichen) car plate
/// against the nationwide and commonly-documented forbidden combinations
/// (FZV §8: identification marks must not offend common decency).
///
/// This is a small, demo-scoped validator -- it checks format and the
/// letter/number combinations most consistently cited across sources. It is
/// NOT an exhaustive reproduction of every municipality's local ban list;
/// those are published separately by each Zulassungsbehörde and change over
/// time. Treat a `true` result as "not obviously forbidden", not as an
/// official registration guarantee.
///
/// In particular the district code is checked for *shape* (1-3 letters) and
/// not for membership of the real `Unterscheidungszeichen` list, so "QQ"
/// validates although no authority issues it. That is deliberate: this package
/// does not promise a district list stays accurate as districts change. A
/// consumer who needs strict district validation composes their own
/// [PlateValidator] with their own list.
library;

import 'package:core_plate/core_plate.dart';

import 'germany_identifier_group.dart';

/// Nationwide-forbidden letter pairs (Nazi-organisation abbreviations) plus
/// widely-documented state-level additions and generically-offensive pairs.
///
/// These consts are the single source of truth for this data.
const Set<String> _forbiddenLetterPairs = {'SS', 'SA', 'KZ', 'HJ', 'NS', 'AH', 'HH', 'SD', 'IS'};

/// Digit strings commonly barred nationwide/regionally for the same reason.
/// Source of truth, as with [_forbiddenLetterPairs].
const Set<String> _forbiddenNumbers = {'88', '18', '14'};

/// The area code may carry an umlaut; the identifier may not. An umlaut in the
/// identifier is the conventional marker of a deliberately fictitious plate, so
/// the asymmetry between these two patterns is the rule, not an oversight.
///
/// All 26 Latin letters are legal in the identifier. B, F and G were barred
/// until 1992 and I, O and Q until 2000 — to keep B/8, F/E, G/6, I/1 and O/Q/0
/// apart — but that restriction is long gone, and a validator still enforcing
/// it would reject a quarter-century of real plates.
///
/// Library-level rather than a static on [GermanPlateValidator] because the
/// area code is the one register every German format shares, and
/// [GermanSerialPlateValidator] checks the same shape.
final RegExp _districtPattern = RegExp(r'^[A-ZÄÖÜ]{1,3}$');
final RegExp _identifierLetterPattern = RegExp(r'^[A-Z]{1,2}$');

/// Validates a German car-plate district code + identifier pair.
///
/// Answers a question — is this plate valid? — and never prevents input. The
/// This class exposes no per-keystroke `barredNext*` helpers and no result
/// typedef — a validator reports a verdict; it does not bar keys.
class GermanPlateValidator extends GatedPlateValidator {
  const GermanPlateValidator();

  @override
  String get gateGroup => 'letters';

  /// Reads the district/letters/serial groups off [entry] by key and
  /// validates them. Returns [PlateValidation.valid] while the 'letters' group
  /// is still blank, mirroring the rule that an in-progress plate shouldn't be
  /// flagged before it's filled in — with nothing barring input, the red state
  /// is the only feedback, and a plate that flashes red on its first character
  /// is worse than no validation.
  @override
  PlateValidation judge(PlateEntry entry) {
    final registration = validateFields(
      district: entry.group('district'),
      identifierLetters: entry.group('letters'),
      identifierDigits: entry.group('serial'),
    );
    if (!registration.isValid) return registration;
    // Empty on every spec that has no season block, so this costs a seasonal
    // plate a check and an ordinary one nothing.
    return validateSeason(start: entry.group('seasonStart'), end: entry.group('seasonEnd'));
  }

  /// The season block: two months of validity, the first printed above the
  /// rule and the last below it.
  ///
  /// Both must be real months. Neither has to precede the other — a vehicle
  /// laid up for the summer is registered `11` over `03`, and a season that
  /// wraps the turn of the year is as ordinary as one that does not. A
  /// validator that insisted on `start < end` would reject every winter plate
  /// in the country.
  ///
  /// Stays quiet about a month that is not yet two digits: the season is the
  /// last thing on the plate to be filled in, and half of `03` is `0`, which is
  /// not a month.
  static PlateValidation validateSeason({required String start, required String end}) {
    for (final month in [start, end]) {
      if (month.length < 2) continue;
      if (!isDigitsOfLength(month, 2)) {
        return const PlateValidation.invalid('A season month is two digits.');
      }
      final value = int.parse(month);
      if (value < 1 || value > 12) {
        return PlateValidation.invalid('"$month" is not a month.');
      }
    }
    return const PlateValidation.valid();
  }

  /// The country rule without a spec: pass the plate's own slot values in.
  ///
  /// [district] is the `Unterscheidungszeichen` (1-3 letters, e.g. "DA").
  /// [identifierLetters] is the 1-2 letter block of the `Erkennungsnummer`
  /// (e.g. "X" or "AB"). [identifierDigits] is the 1-4 digit serial (e.g.
  /// "1953"). Named [validateFields] rather than overloading the instance
  /// [validate]; the instance method delegates to it.
  static PlateValidation validateFields({
    required String district,
    required String identifierLetters,
    required String identifierDigits,
  }) {
    final d = district.toUpperCase();
    final letters = identifierLetters.toUpperCase();
    final digits = identifierDigits;

    if (!_districtPattern.hasMatch(d)) {
      return const PlateValidation.invalid('District code must be 1-3 letters.');
    }

    if (!_identifierLetterPattern.hasMatch(letters)) {
      return const PlateValidation.invalid('Identifier letters must be 1-2 letters.');
    }

    if (digits.isNotEmpty && !(isDigits(digits) && digits.length <= 4)) {
      return const PlateValidation.invalid('Identifier digits must be 1-4 digits.');
    }

    // A serial is a number, and numbers are not written with leading zeros:
    // "HH-JB 007" is not issuable, which is why the vanity-plate advice is to
    // reach for "HH-J 8007" or "HH-OO 7" instead.
    if (digits.startsWith('0')) {
      return const PlateValidation.invalid('The serial cannot start with 0.');
    }

    if (d.length + letters.length + digits.length > 8) {
      return const PlateValidation.invalid('Plate exceeds the 8-character maximum.');
    }

    // The identifier's shape must be one of the five groups in FZV Appendix 1;
    // "AB" with no digits, or "A" with no digits, is well-formed but not a
    // shape anyone issues. Checked after the length cap so that an over-long
    // plate reports the cap, which is the more useful complaint.
    if (digits.isNotEmpty && GermanIdentifierGroup.of(letters: letters.length, digits: digits.length) == null) {
      return PlateValidation.invalid(
        '${letters.length} letter(s) and ${digits.length} digit(s) is not an issued identifier shape.',
      );
    }

    if (_forbiddenLetterPairs.contains(letters)) {
      return PlateValidation.invalid('"$letters" is a forbidden combination.');
    }

    // The same pairs are avoided where they straddle the gap: Hanover,
    // Nuremberg, Cologne and Stuttgart issue no one-letter identifiers, because
    // H-J, N-S, K-Z, S-A, S-D and S-S would read as the banned pair. Only
    // reachable since the area code became variable-length — a two-letter code
    // with a one-letter identifier spans three characters, not two.
    //
    // Note that this is *not* symmetric with the area code itself: HH
    // (Hansestadt Hamburg) and AH (Ahaus) are legal codes and are not checked
    // here, even though both appear in [_forbiddenLetterPairs].
    if (d.length == 1 && letters.length == 1 && _forbiddenLetterPairs.contains('$d$letters')) {
      return PlateValidation.invalid('"$d$letters" is a forbidden combination.');
    }

    if (digits.isNotEmpty && _forbiddenNumbers.contains(digits)) {
      return PlateValidation.invalid('"$digits" is a forbidden combination.');
    }

    return const PlateValidation.valid();
  }
}

/// Validates a number that is not a registration: the `06` dealer plate and
/// the `07` collector plate, each an area code followed by five digits opening
/// with the two the format is named for.
///
/// A sibling of [GermanPlateValidator] rather than a mode of it. Almost every
/// rule that class enforces is false here — a five-digit serial where the
/// register holds four, a leading zero where a registration may never have one,
/// and no identifier letters at all to gate on or to check against the
/// forbidden pairs. Bending it to cover both would leave a validator whose
/// every rule is conditional on which plate it was handed; two small classes
/// and [GermanPlates.validatorFor] to choose between them is the honest shape.
///
/// One class for both numbers, though, because they differ in exactly one
/// datum. See `core_plate/CLAUDE.md`: variation is data.
class GermanSerialPlateValidator extends GatedPlateValidator {
  /// The `06` number a garage moves between vehicles for test drives.
  const GermanSerialPlateValidator.dealer() : prefix = '06';

  /// The `07` number a collector uses across the vehicles in one collection.
  const GermanSerialPlateValidator.collector() : prefix = '07';

  /// The two digits the serial opens with.
  final String prefix;

  /// The serial, not the letters: there are no identifier letters on these
  /// plates, so the area code is the only other register and it fills first.
  @override
  String get gateGroup => 'serial';

  @override
  PlateValidation judge(PlateEntry entry) {
    final district = entry.group('district').toUpperCase();
    final serial = entry.group('serial');

    if (!_districtPattern.hasMatch(district)) {
      return const PlateValidation.invalid('District code must be 1-3 letters.');
    }
    if (!isDigits(serial)) {
      return const PlateValidation.invalid('The number must be digits.');
    }
    // Quiet until the serial is long enough to have contradicted the prefix:
    // "0" is on its way to "06", and flagging it would make the plate flash red
    // at the first keystroke of a number that is going to be fine.
    if (!prefix.startsWith(serial.substring(0, serial.length.clamp(0, 2)))) {
      return PlateValidation.invalid('This number begins "$prefix".');
    }
    if (serial.length < 5) return const PlateValidation.valid();
    if (serial.length > 5) {
      return const PlateValidation.invalid('The number is five digits.');
    }
    return const PlateValidation.valid();
  }
}

/// Validates a number that expires: the `04` short-term plate and the export
/// plate (`Ausfuhrkennzeichen`), each an area code, a five-digit number, and a
/// date stacked DD over MM over YY on the coloured band at the right.
///
/// Sibling to [GermanPlateValidator] and [GermanSerialPlateValidator] rather
/// than a mode of either. These plates carry six digits of date that no
/// registration has, their number has no identifier letters to gate on, and a
/// leading zero is not merely legal but the format's own name: `04401` is what
/// a short-term number looks like.
///
/// One class for both, because — exactly as with the `06` and `07` numbers —
/// they differ in one datum. See `core_plate/CLAUDE.md`: variation is data.
class GermanDatedPlateValidator extends GatedPlateValidator {
  /// The `04` number, valid for at most four weeks. Its serial opens `04`.
  const GermanDatedPlateValidator.shortTerm() : prefix = '04';

  /// The export number, valid for at most a year. Its serial is not reserved
  /// to an opening pair, so there is nothing to check it against.
  const GermanDatedPlateValidator.export() : prefix = null;

  /// The two digits the number opens with, or null when the format reserves
  /// none.
  final String? prefix;

  /// The date, not the number: the band is the last thing on these plates to
  /// be filled in, so by the time it has a character there is a whole plate to
  /// judge.
  @override
  String get gateGroup => 'expiryDay';

  @override
  PlateValidation judge(PlateEntry entry) {
    final district = entry.group('district').toUpperCase();
    final serial = entry.group('serial');

    if (!_districtPattern.hasMatch(district)) {
      return const PlateValidation.invalid('District code must be 1-3 letters.');
    }
    if (!isDigits(serial)) {
      return const PlateValidation.invalid('The number must be digits.');
    }
    final prefix = this.prefix;
    if (prefix != null && !prefix.startsWith(serial.substring(0, serial.length.clamp(0, 2)))) {
      return PlateValidation.invalid('This number begins "$prefix".');
    }
    if (serial.length > 5) {
      return const PlateValidation.invalid('The number is five digits.');
    }
    return validateExpiry(
      day: entry.group('expiryDay'),
      month: entry.group('expiryMonth'),
      year: entry.group('expiryYear'),
    );
  }

  /// The date on the band: a day, a month and a two-digit year, each printed
  /// on its own row.
  ///
  /// Quiet about a field that is not yet two digits — half of `03` is `0`,
  /// which is not a month — and about the year entirely: every two-digit year
  /// is a year, and the plate carries no century to check it against.
  ///
  /// Checks the day against the month's own length, so `31/04` is rejected and
  /// `29/02` is not: a two-digit year cannot say which century it is in, so
  /// there is no way to know whether that February had a 29th.
  static PlateValidation validateExpiry({required String day, required String month, required String year}) {
    for (final (name, value) in [('day', day), ('month', month), ('year', year)]) {
      if (value.isEmpty || value.length < 2) continue;
      if (!isDigitsOfLength(value, 2)) {
        return PlateValidation.invalid('The expiry $name is two digits.');
      }
    }
    if (month.length == 2 && isDigits(month)) {
      final m = int.parse(month);
      if (m < 1 || m > 12) return PlateValidation.invalid('"$month" is not a month.');
      if (day.length == 2 && isDigits(day)) {
        final d = int.parse(day);
        if (d < 1 || d > _daysInMonth[m - 1]) {
          return PlateValidation.invalid('"$day" is not a day of month $month.');
        }
      }
    } else if (day.length == 2 && isDigits(day)) {
      final d = int.parse(day);
      if (d < 1 || d > 31) return PlateValidation.invalid('"$day" is not a day.');
    }
    return const PlateValidation.valid();
  }

  /// February's 29 is the leap year's, not a mistake: a two-digit year names
  /// no century, so there is nothing here to work a leap rule out from.
  static const List<int> _daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
}

/// Validates a Bundeswehr `Y` plate: the fixed `Y` in the area code's
/// position, then six digits printed as two triples.
///
/// The `Y` has been the German armed forces' mark since 1956 — it stands for
/// nothing, which was the point: it was picked because no *Unterscheidungs-
/// zeichen* used it. This validator is what says the area code must read `Y`;
/// the character is a slot rather than a printed label because on every German
/// format in this package the area code is a register, and one format printing
/// its own would be the odd one out.
class GermanBundeswehrValidator extends GatedPlateValidator {
  const GermanBundeswehrValidator();

  /// The second triple: it fills last, so by the time it has a character the
  /// whole number is there to judge.
  @override
  String get gateGroup => 'serialTail';

  @override
  PlateValidation judge(PlateEntry entry) {
    final district = entry.group('district').toUpperCase();
    if (district != 'Y') {
      return const PlateValidation.invalid('A Bundeswehr plate begins "Y".');
    }
    final serial = entry.group('serial') + entry.group('serialTail');
    if (!isDigits(serial)) {
      return const PlateValidation.invalid('The number must be digits.');
    }
    if (serial.length > 6) {
      return const PlateValidation.invalid('The number is six digits.');
    }
    return const PlateValidation.valid();
  }
}
