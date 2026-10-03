import 'package:core_plate/core_plate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:germany_plate/germany_plate.dart';

/// The rules [GermanPlateValidator] claims to enforce, one test each.
///
/// The validator is advisory by design — it checks shape and the combinations
/// consistently documented nationwide, not every municipality's local ban list
/// — so these pin what it *does* decide and nothing about districts it declines
/// to know about.
void main() {
  bool ok(String district, String letters, String digits) =>
      GermanPlateValidator.validateFields(
        district: district,
        identifierLetters: letters,
        identifierDigits: digits,
      ).isValid;

  group('shape', () {
    test('accepts one, two and three letter area codes', () {
      expect(ok('B', 'AB', '123'), isTrue);
      expect(ok('DA', 'X', '1953'), isTrue);
      expect(ok('CUX', 'DP', '150'), isTrue);
    });

    test('rejects a four-letter area code', () {
      expect(ok('CUXX', 'D', '150'), isFalse);
    });

    test('accepts an umlaut in the area code but not the identifier', () {
      expect(ok('GÖ', 'X', '2495'), isTrue);
      expect(
        ok('WÜ', 'NK', '88'),
        isFalse,
      ); // 88 is barred, but for its own reason
      expect(ok('WÜ', 'NK', '89'), isTrue);
      expect(ok('M', 'Ü', '1234'), isFalse);
    });

    test('accepts the letters unbarred in 1992 and 2000', () {
      for (final letter in ['B', 'F', 'G', 'I', 'O', 'Q']) {
        expect(ok('M', letter, '1234'), isTrue, reason: letter);
      }
    });
  });

  group('the eight-character maximum', () {
    test('accepts exactly eight', () {
      expect(ok('CUX', 'DP', '150'), isTrue);
    });

    test('rejects nine — group e behind a three-letter code', () {
      expect(ok('CUX', 'DP', '1500'), isFalse);
    });
  });

  group('issued identifier groups', () {
    test('accepts one of each', () {
      expect(ok('M', 'A', '1'), isTrue); // a
      expect(ok('M', 'AB', '12'), isTrue); // b
      expect(ok('M', 'AB', '123'), isTrue); // c
      expect(ok('M', 'A', '1234'), isTrue); // d
      expect(ok('M', 'AB', '1234'), isTrue); // e
    });

    test('stays quiet while the serial is still being typed', () {
      expect(ok('M', 'AB', ''), isTrue);
    });
  });

  group('the serial', () {
    test('cannot start with a zero', () {
      expect(ok('HH', 'JB', '007'), isFalse);
      expect(ok('HH', 'J', '8007'), isTrue);
    });

    test('bars the documented numbers', () {
      for (final digits in ['88', '18', '14']) {
        expect(ok('M', 'AB', digits), isFalse, reason: digits);
      }
    });
  });

  group('forbidden combinations', () {
    test('bars the pairs in the identifier', () {
      for (final letters in ['SS', 'SA', 'KZ', 'HJ', 'NS', 'AH', 'HH', 'SD']) {
        expect(ok('M', letters, '123'), isFalse, reason: letters);
      }
    });

    test('bars them where they straddle the gap', () {
      expect(ok('H', 'J', '123'), isFalse);
      expect(ok('K', 'Z', '123'), isFalse);
      expect(ok('S', 'A', '123'), isFalse);
    });

    test('allows them as area codes — HH is Hamburg, AH was Ahaus', () {
      expect(ok('HH', 'XY', '123'), isTrue);
      expect(ok('AH', 'XY', '123'), isTrue);
    });

    test('allows what the authorities allow', () {
      expect(ok('AC', 'AB', '123'), isTrue);
      expect(ok('SE', 'XY', '123'), isTrue);
    });
  });

  group('the season', () {
    bool season(String start, String end) =>
        GermanPlateValidator.validateSeason(start: start, end: end).isValid;

    test('accepts a pair of real months', () {
      expect(season('03', '10'), isTrue);
      expect(season('01', '12'), isTrue);
    });

    test('accepts a season that wraps the year', () {
      // A vehicle laid up for the summer. Requiring start < end would reject
      // every winter plate in the country.
      expect(season('11', '03'), isTrue);
    });

    test('rejects a month that is not a month', () {
      expect(season('00', '10'), isFalse);
      expect(season('03', '13'), isFalse);
      expect(season('99', '99'), isFalse);
    });

    test('stays quiet while a month is still being typed', () {
      expect(season('0', ''), isTrue);
      expect(season('03', '1'), isTrue);
    });

    test('is read off a seasonal spec and ignored on every other', () {
      final seasonal = GermanPlates.seasonalFor();
      expect(GermanPlates.isSeasonal(seasonal), isTrue);
      expect(GermanPlates.isSeasonal(GermanPlates.car), isFalse);

      const validator = GermanPlateValidator();
      // HR · K 1953, valid from month 03 to month 13.
      final values = 'HRK19530313'.split('');
      expect(
        validator.validate(PlateEntry(spec: seasonal, values: values)).isValid,
        isFalse,
      );
      values[10] = '0';
      expect(
        validator.validate(PlateEntry(spec: seasonal, values: values)).isValid,
        isTrue,
      );
    });
  });

  group('the 06 and 07 numbers', () {
    // Padded to the spec's slot count, so a half-typed number is the empty
    // tail it would really be rather than a short list.
    PlateValidation judge(PlateSpec spec, String typed) {
      final values = List<String?>.filled(spec.slotCount, null);
      for (var i = 0; i < typed.length; i++) {
        values[i] = typed[i];
      }
      return GermanPlates.validatorFor(
        spec,
      ).validate(PlateEntry(spec: spec, values: values));
    }

    test('the right validator is chosen from the spec', () {
      expect(
        GermanPlates.validatorFor(GermanPlates.dealerFor()),
        isA<GermanSerialPlateValidator>(),
      );
      expect(
        GermanPlates.validatorFor(GermanPlates.collectorFor()),
        isA<GermanSerialPlateValidator>(),
      );
      expect(
        GermanPlates.validatorFor(GermanPlates.car),
        isA<GermanPlateValidator>(),
      );
      expect(
        GermanPlates.validatorFor(GermanPlates.seasonalFor()),
        isA<GermanPlateValidator>(),
      );
    });

    test('accepts the five digits the car validator would reject outright', () {
      // Leading zero, five digits, no identifier letters: three rules of
      // GermanPlateValidator's broken at once, and all three correct here.
      expect(judge(GermanPlates.dealerFor(), 'WÜ06131').isValid, isTrue);
      expect(
        judge(
          GermanPlates.collectorFor(districtLetters: 3),
          'SDL07001',
        ).isValid,
        isTrue,
      );
    });

    test('rejects the other format\'s prefix', () {
      expect(judge(GermanPlates.dealerFor(), 'WÜ07131').isValid, isFalse);
      expect(judge(GermanPlates.collectorFor(), 'SD06001').isValid, isFalse);
    });

    test('stays quiet while the number is still being typed', () {
      final spec = GermanPlates.dealerFor();
      expect(judge(spec, 'WÜ0').isValid, isTrue);
      expect(judge(spec, 'WÜ06').isValid, isTrue);
      expect(judge(spec, 'WÜ061').isValid, isTrue);
      // ...but a first digit that cannot become 06 is wrong the moment it lands.
      expect(judge(spec, 'WÜ1').isValid, isFalse);
    });
  });

  group('the 04 and export numbers', () {
    PlateValidation judge(PlateSpec spec, String typed) {
      final values = List<String?>.filled(spec.slotCount, null);
      for (var i = 0; i < typed.length; i++) {
        values[i] = typed[i];
      }
      return GermanPlates.validatorFor(
        spec,
      ).validate(PlateEntry(spec: spec, values: values));
    }

    test('the right validator is chosen from the spec', () {
      expect(
        GermanPlates.validatorFor(GermanPlates.shortTermFor()),
        isA<GermanDatedPlateValidator>(),
      );
      expect(
        GermanPlates.validatorFor(GermanPlates.exportFor()),
        isA<GermanDatedPlateValidator>(),
      );
    });

    test('a leading zero is the format, not a fault', () {
      // KA · 04401, expiring 09/03/04 — the photographed plate.
      expect(
        judge(GermanPlates.shortTermFor(), 'KA04401090304').isValid,
        isTrue,
      );
    });

    test(
      '04 is reserved to the short-term number and free on the export one',
      () {
        expect(
          judge(GermanPlates.shortTermFor(), 'KA05401090304').isValid,
          isFalse,
        );
        // The export number reserves no opening pair, so the same serial passes.
        expect(
          judge(GermanPlates.exportFor(), 'KA05401090304').isValid,
          isTrue,
        );
      },
    );

    test('stays quiet until the date has been reached', () {
      // Wrong on every count — five letters would fit, and the number does not
      // open 04 — but the band is still blank, so there is nothing to judge.
      expect(judge(GermanPlates.shortTermFor(), 'KA99999').isValid, isTrue);
    });

    group('the expiry date', () {
      bool date(String day, String month, String year) =>
          GermanDatedPlateValidator.validateExpiry(
            day: day,
            month: month,
            year: year,
          ).isValid;

      test('accepts a real date', () {
        expect(date('09', '03', '04'), isTrue);
        expect(date('31', '12', '99'), isTrue);
      });

      test('rejects a month that is not one', () {
        expect(date('09', '13', '04'), isFalse);
        expect(date('09', '00', '04'), isFalse);
      });

      test('rejects a day the month does not have', () {
        expect(date('31', '04', '04'), isFalse);
        expect(date('30', '02', '04'), isFalse);
        expect(date('00', '03', '04'), isFalse);
      });

      test(
        'lets February keep its 29th — a two-digit year names no century',
        () {
          expect(date('29', '02', '04'), isTrue);
        },
      );

      test('takes any two-digit year, and stays quiet mid-keystroke', () {
        expect(date('09', '03', '00'), isTrue);
        expect(date('3', '', ''), isTrue);
        expect(date('31', '0', ''), isTrue);
      });
    });
  });

  group('the Bundeswehr number', () {
    PlateValidation judge(String typed) {
      final spec = GermanPlates.bundeswehrFor();
      final values = List<String?>.filled(spec.slotCount, null);
      for (var i = 0; i < typed.length; i++) {
        values[i] = typed[i];
      }
      return GermanPlates.validatorFor(
        spec,
      ).validate(PlateEntry(spec: spec, values: values));
    }

    test('the right validator is chosen from the spec', () {
      expect(
        GermanPlates.validatorFor(GermanPlates.bundeswehrFor()),
        isA<GermanBundeswehrValidator>(),
      );
    });

    test('accepts Y and six digits', () {
      expect(judge('Y751957').isValid, isTrue);
      // A leading zero is fine: this is a number the forces issue, not a
      // registration.
      expect(judge('Y012345').isValid, isTrue);
    });

    test('rejects an area code that is not Y', () {
      expect(judge('X751957').isValid, isFalse);
    });

    test('stays quiet until the second triple is reached', () {
      expect(judge('X751').isValid, isTrue);
    });
  });
}
