import 'package:core_plate/core_plate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:germany_plate/germany_plate.dart';

/// Every spec this package declares. Only one, so this is a literal list
/// rather than a lookup sweep — see `yemen_plate/test/yemen_specs_test.dart`
/// and `palestine_plate/test/spec_validation_test.dart` for the shape this
/// mirrors.
void main() {
  final specs = <PlateSpec>[GermanPlates.car];

  test('every keyed register is evenly pitched', () {
    for (final spec in specs) {
      var ok = false;
      assert(ok = debugValidateSpec(spec));
      expect(ok, isTrue, reason: spec.id);
    }
  });
}
