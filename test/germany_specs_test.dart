import 'package:core_plate/core_plate.dart';
import 'package:flutter/widgets.dart';
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

  test('no registration exceeds the eight-character maximum', () {
    for (final spec in [...GermanPlates.allCars, ...GermanPlates.allCarVariants]) {
      // The cap is on the registration. A suffix counts against it and is a
      // label rather than a slot; the season months do not count at all —
      // they are a validity period printed on the plate, not part of the
      // number — so they are subtracted back out here.
      final registration =
          spec.slotCount + GermanPlates.suffixOf(spec).length - (GermanPlates.isSeasonal(spec) ? 4 : 0);
      expect(registration, lessThanOrEqualTo(8), reason: spec.id);
    }
  });

  test('the 06 and 07 numbers are deliberately outside those rules', () {
    for (final spec in GermanPlates.allSerialPlates) {
      // Five digits and no identifier letters — the shape that made these
      // their own specs rather than carFor with an argument.
      expect(spec.valueOfGroup('letters', List.filled(spec.slotCount, 'X')), isEmpty, reason: spec.id);
      expect(spec.valueOfGroup('serial', List.filled(spec.slotCount, '0')), hasLength(5), reason: spec.id);
    }
  });

  test('the 04 and export numbers are one geometry in two colours', () {
    final shortTerm = GermanPlates.shortTermFor();
    final export = GermanPlates.exportFor();

    expect(shortTerm.canvasWidth, export.canvasWidth);
    expect(shortTerm.background.parts.first.end, export.background.parts.first.end);
    expect(
      shortTerm.background.parts.last.section.fill!.color,
      isNot(export.background.parts.last.section.fill!.color),
    );
    // Black on white, both of them: the band is a field, not an ink.
    expect(shortTerm.inkOverride, isNull);
    expect(export.inkOverride, isNull);
  });

  test('the dated plates carry no euroband and one seal', () {
    for (final spec in GermanPlates.allDatedPlates) {
      expect(spec.noPanel, isTrue, reason: spec.id);
      expect(spec.decals, hasLength(1), reason: spec.id);
      // Five digits of number, and six of date in three rows of two.
      expect(spec.valueOfGroup('serial', List.filled(spec.slotCount, '0')), hasLength(5), reason: spec.id);
      for (final key in ['expiryDay', 'expiryMonth', 'expiryYear']) {
        expect(spec.valueOfGroup(key, List.filled(spec.slotCount, '0')), hasLength(2), reason: '${spec.id} $key');
      }
      // The band is the last column: it runs to the plate's right-hand edge
      // and the full height.
      expect(spec.background.axis, Axis.horizontal, reason: spec.id);
      expect(spec.background.parts.last.end, isNull, reason: spec.id);
      expect(spec.background.parts.last.section.fill!.color, isNotNull, reason: spec.id);
    }
  });

  test('the Bundeswehr number is the flag block, a printed hyphen and two triples', () {
    final spec = GermanPlates.bundeswehrFor();

    expect(spec.noPanel, isFalse);
    expect(spec.country, GermanyCountry.bundeswehr);
    expect(spec.panel.box.width, lessThan(GermanPlates.car.panel.box.width));
    expect(spec.labels.map((l) => l.text), ['-']);
    // The seal alone: a military vehicle records no Hauptuntersuchung.
    expect(spec.decals, hasLength(1));
    expect(spec.slotCount, 7);
    final filled = List.filled(spec.slotCount, '0');
    expect(spec.valueOfGroup('serial', filled) + spec.valueOfGroup('serialTail', filled), hasLength(6));
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
