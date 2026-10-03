/// Validates a German (Kennzeichen) car plate. Demo-scoped: checks format and
/// commonly-documented forbidden combinations, not the full municipality lists
/// published by each Zulassungsbehörde. District codes are validated by shape
/// (1-3 letters) only, not by membership in the real Unterscheidungszeichen.
library;

import 'package:core_plate/core_plate.dart';

import 'germany_identifier_group.dart';

/// Nationwide-forbidden letter pairs (Nazi-organisation abbreviations) plus
/// widely-documented state-level additions and generically-offensive pairs.
///
/// These consts are the single source of truth for this data.
const Set<String> _forbiddenLetterPairs = {
  'SS',
  'SA',
  'KZ',
  'HJ',
  'NS',
  'AH',
  'HH',
  'SD',
  'IS',
};

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
class GermanPlateValidator extends GatedPlateValidator {
  const GermanPlateValidator();

  @override
  String get gateGroup => 'letters';

  /// Validates groups: district, letters, and serial. Quiet while letters are
  /// empty (do not flag incomplete plates).
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
    return validateSeason(
      start: entry.group('seasonStart'),
      end: entry.group('seasonEnd'),
    );
  }

  /// Two months of validity (e.g., 03–10 for spring/fall). No order required:
  /// 11–03 is valid (winter). Quiet about incomplete months (e.g., '0').
  static PlateValidation validateSeason({
    required String start,
    required String end,
  }) {
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

  static PlateValidation validateFields({
    required String district,
    required String identifierLetters,
    required String identifierDigits,
  }) {
    final d = district.toUpperCase();
    final letters = identifierLetters.toUpperCase();
    final digits = identifierDigits;

    if (!_districtPattern.hasMatch(d)) {
      return const PlateValidation.invalid(
        'District code must be 1-3 letters.',
      );
    }

    if (!_identifierLetterPattern.hasMatch(letters)) {
      return const PlateValidation.invalid(
        'Identifier letters must be 1-2 letters.',
      );
    }

    if (digits.isNotEmpty && !(isDigits(digits) && digits.length <= 4)) {
      return const PlateValidation.invalid(
        'Identifier digits must be 1-4 digits.',
      );
    }

    if (digits.startsWith('0')) {
      return const PlateValidation.invalid('The serial cannot start with 0.');
    }

    if (d.length + letters.length + digits.length > 8) {
      return const PlateValidation.invalid(
        'Plate exceeds the 8-character maximum.',
      );
    }

    if (digits.isNotEmpty &&
        GermanIdentifierGroup.of(
              letters: letters.length,
              digits: digits.length,
            ) ==
            null) {
      return PlateValidation.invalid(
        '${letters.length} letter(s) and ${digits.length} digit(s) is not an issued identifier shape.',
      );
    }

    if (_forbiddenLetterPairs.contains(letters)) {
      return PlateValidation.invalid('"$letters" is a forbidden combination.');
    }

    if (d.length == 1 &&
        letters.length == 1 &&
        _forbiddenLetterPairs.contains('$d$letters')) {
      return PlateValidation.invalid(
        '"$d$letters" is a forbidden combination.',
      );
    }

    if (digits.isNotEmpty && _forbiddenNumbers.contains(digits)) {
      return PlateValidation.invalid('"$digits" is a forbidden combination.');
    }

    return const PlateValidation.valid();
  }
}

/// Validates a `06` dealer or `07` collector plate: area code + 5 digits starting
/// with 06/07. Sibling to [GermanPlateValidator] because these are not registrations.
class GermanSerialPlateValidator extends GatedPlateValidator {
  /// The `06` number a garage moves between vehicles for test drives.
  const GermanSerialPlateValidator.dealer() : prefix = '06';

  /// The `07` number a collector uses across the vehicles in one collection.
  const GermanSerialPlateValidator.collector() : prefix = '07';

  /// The two digits the serial opens with.
  final String prefix;

  @override
  String get gateGroup => 'serial';

  @override
  PlateValidation judge(PlateEntry entry) {
    final district = entry.group('district').toUpperCase();
    final serial = entry.group('serial');

    if (!_districtPattern.hasMatch(district)) {
      return const PlateValidation.invalid(
        'District code must be 1-3 letters.',
      );
    }
    if (!isDigits(serial)) {
      return const PlateValidation.invalid('The number must be digits.');
    }
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

/// Validates a `04` short-term or export plate: area code + 5 digits (opening
/// 04 for short-term) + expiry date. Sibling to [GermanPlateValidator].
class GermanDatedPlateValidator extends GatedPlateValidator {
  /// The `04` number, valid for at most four weeks. Its serial opens `04`.
  const GermanDatedPlateValidator.shortTerm() : prefix = '04';

  /// The export number, valid for at most a year. Its serial is not reserved
  /// to an opening pair, so there is nothing to check it against.
  const GermanDatedPlateValidator.export() : prefix = null;

  /// The two digits the number opens with, or null when the format reserves
  /// none.
  final String? prefix;

  @override
  String get gateGroup => 'expiryDay';

  @override
  PlateValidation judge(PlateEntry entry) {
    final district = entry.group('district').toUpperCase();
    final serial = entry.group('serial');

    if (!_districtPattern.hasMatch(district)) {
      return const PlateValidation.invalid(
        'District code must be 1-3 letters.',
      );
    }
    if (!isDigits(serial)) {
      return const PlateValidation.invalid('The number must be digits.');
    }
    final prefix = this.prefix;
    if (prefix != null &&
        !prefix.startsWith(serial.substring(0, serial.length.clamp(0, 2)))) {
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

  /// DD/MM/YY on the band. Quiet on incomplete fields. Checks day against month
  /// length, but treats February as having 29 days (ambiguous century).
  static PlateValidation validateExpiry({
    required String day,
    required String month,
    required String year,
  }) {
    for (final (name, value) in [
      ('day', day),
      ('month', month),
      ('year', year),
    ]) {
      if (value.isEmpty || value.length < 2) continue;
      if (!isDigitsOfLength(value, 2)) {
        return PlateValidation.invalid('The expiry $name is two digits.');
      }
    }
    if (month.length == 2 && isDigits(month)) {
      final m = int.parse(month);
      if (m < 1 || m > 12)
        return PlateValidation.invalid('"$month" is not a month.');
      if (day.length == 2 && isDigits(day)) {
        final d = int.parse(day);
        if (d < 1 || d > _daysInMonth[m - 1]) {
          return PlateValidation.invalid(
            '"$day" is not a day of month $month.',
          );
        }
      }
    } else if (day.length == 2 && isDigits(day)) {
      final d = int.parse(day);
      if (d < 1 || d > 31)
        return PlateValidation.invalid('"$day" is not a day.');
    }
    return const PlateValidation.valid();
  }

  static const List<int> _daysInMonth = [
    31,
    29,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];
}

/// Validates a Bundeswehr `Y` plate: `Y` in the area code, then six digits.
class GermanBundeswehrValidator extends GatedPlateValidator {
  const GermanBundeswehrValidator();

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
