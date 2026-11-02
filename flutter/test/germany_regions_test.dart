import 'package:flutter_test/flutter_test.dart';
import 'package:germany_plate/germany_plate.dart';
import 'package:plate_core/plate_core.dart';

void main() {
  test('a code names its district, or its state when it needs two rows', () {
    expect(GermanyRegions.lookup('AA'), 'Ostalb District (Baden-Württemberg)');
    expect(GermanyRegions.lookup('B'), 'Berlin');
    expect(GermanyRegions.lookup('HH'), 'Hamburg');
    expect(GermanyRegions.lookup('M'), 'Bavaria');
  });

  test('a prefix shared by several places, or by none, names nothing', () {
    for (final String code in <String>['', 'Q', 'QQQ']) {
      expect(GermanyRegions.lookup(code), isNull, reason: code);
    }
  });

  test('the car plate follows the code typed and deleted', () {
    final PlateController c = PlateController(spec: GermanPlates.car);
    expect(c.regionCaption, isNull);
    c.setGroup('district', 'B');
    expect(c.regionCaption, 'Berlin');
    c.setGroup('district', 'AA');
    expect(c.regionCaption, 'Ostalb District (Baden-Württemberg)');
    c.setGroup('district', '');
    expect(c.regionCaption, isNull);
  });
}
