import 'package:flutter_test/flutter_test.dart';
import 'package:germany_plate/germany_plate.dart';

/// The rules [GermanPlateValidator] claims to enforce, one test each.
///
/// The validator is advisory by design — it checks shape and the combinations
/// consistently documented nationwide, not every municipality's local ban list
/// — so these pin what it *does* decide and nothing about districts it declines
/// to know about.
void main() {
  bool ok(String district, String letters, String digits) => GermanPlateValidator.validateFields(
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
      expect(ok('WÜ', 'NK', '88'), isFalse); // 88 is barred, but for its own reason
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
}
