import 'package:core_plate/core_plate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:germany_plate/germany_plate.dart';

/// Every spec this package declares. [GermanPlates.allSpecs] is that list —
/// there is no hand-written copy of the shapes here, so a spec added to the
/// library is swept without this file changing. See
/// `yemen_plate/test/yemen_specs_test.dart` and
/// `palestine_plate/test/spec_validation_test.dart` for the shape this mirrors.
void main() {
  test('every keyed register is evenly pitched', () {
    for (final spec in GermanPlates.allSpecs) {
      var ok = false;
      assert(ok = debugValidateSpec(spec));
      expect(ok, isTrue, reason: spec.id);
    }
  });

  test('every spec is uniquely identified, and the common one keeps the bare id', () {
    final ids = GermanPlates.allSpecs.map((s) => s.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(ids, contains('de.car'));
    expect(GermanPlates.car.id, 'de.car');
  });

  test('no car spec exceeds the eight-character maximum', () {
    for (final spec in GermanPlates.allSpecs) {
      // A suffix counts against the cap, and it is a label rather than a slot.
      final suffix = GermanPlates.suffixOf(spec).length;
      expect(spec.slotCount + suffix, lessThanOrEqualTo(8), reason: spec.id);
    }
  });

  test('a shorter plate has a shorter canvas', () {
    final short = GermanPlates.carFor(districtLetters: 1, group: GermanIdentifierGroup.a, digits: 1);
    final long = GermanPlates.carFor(districtLetters: 3, group: GermanIdentifierGroup.c);

    expect(short.canvasWidth, lessThan(long.canvasWidth));
    expect(short.canvasHeight, long.canvasHeight);
    // Character cells keep their size whatever the plate's length: a plate with
    // few characters is shorter, not wider-tracked.
    expect(short.slots.first.box.width, long.slots.first.box.width);
  });

  test('the default keeps the geometry the golden pins', () {
    final spec = GermanPlates.car;
    expect(spec.canvasWidth, 520);
    expect(spec.slotCount, 7);
    expect(spec.slots[0].box.left, 64);
    expect(spec.slots[1].box.left, 122);
    expect(spec.slots[2].box.left, 230);
    expect(spec.slots[3].box.left, 288);
    expect(spec.decals.first.box.left, 184);
  });

  test('the area code takes umlauts and the identifier does not', () {
    final spec = GermanPlates.car;
    expect(spec.slots[0].alphabet.accepts('Ü'), isTrue);
    expect(spec.slots[2].alphabet.accepts('Ü'), isFalse);
    expect(spec.slots[0].alphabet.accepts('ẞ'), isFalse);
  });

  group('carFor rejects shapes the law does not issue', () {
    test('a four-letter area code', () {
      expect(() => GermanPlates.carFor(districtLetters: 4), throwsArgumentError);
    });

    test('a serial length outside the group', () {
      expect(() => GermanPlates.carFor(group: GermanIdentifierGroup.b, digits: 3), throwsArgumentError);
    });

    test('group e behind a three-letter area code', () {
      expect(() => GermanPlates.carFor(districtLetters: 3, group: GermanIdentifierGroup.e), throwsArgumentError);
    });
  });
}
