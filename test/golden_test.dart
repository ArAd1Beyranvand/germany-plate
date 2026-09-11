import 'package:core_plate/core_plate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:germany_plate/germany_plate.dart';

/// One golden for `GermanPlates.car`, filled with a valid value — LTR layout,
/// the two `PlateDecal` raster stickers, and the EU panel. Modelled on
/// `palestine_plate/test/golden_test.dart`.
///
/// Regenerate with `flutter test --update-goldens` after a deliberate change.
void main() {
  testWidgets('car, valid value (LTR, decals, EU panel)', (tester) async {
    final spec = GermanPlates.car;
    final controller = PlateController.fromValues(spec, const ['D', 'A', 'X', '1', '9', '5', '3']);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 520,
              height: 520 * spec.canvasHeight / spec.canvasWidth,
              child: PlateView(controller: controller),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(find.byType(PlateView), matchesGoldenFile('goldens/de_car.png'));

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
