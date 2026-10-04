import 'package:plate_core/plate_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:germany_plate/germany_plate.dart';

/// One golden per variant: the standard car, the shapes that stretch the
/// canvas, and each printed variation built on that geometry. A variant that
/// differs only in data still gets a picture, because "only in data" is exactly
/// the claim worth checking — a green plate that came out black, or an `H` that
/// landed a pitch too far right, is invisible in a unit test and obvious here.
///
/// Modelled on `palestine_plate/test/golden_test.dart`.
///
/// Run these from inside `germany_plate/`, not from the workspace root: the
/// decal rasters and the flag SVG are this package's assets, and `flutter test
/// germany_plate` invoked from the root bundles the root package's assets
/// instead, so every image renders as an error placeholder. Regenerate with
/// `flutter test --update-goldens` after a deliberate change.
void main() {
  Future<void> renderGolden(
    WidgetTester tester, {
    required PlateSpec spec,
    required String values,
  }) async {
    final controller = PlateController.fromValues(spec, values.split(''));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              // Plate-space width, so a shorter plate is drawn shorter rather
              // than scaled up to fill a fixed box — which is the whole point
              // of the variable canvas.
              width: spec.canvasWidth,
              height: spec.canvasHeight,
              child: PlateView(controller: controller),
            ),
          ),
        ),
      ),
    );
    // The decal rasters and the panel's SVG are loaded and decoded off the real
    // event loop, which fake time does not advance — so pumpAndSettle alone can
    // capture the frame while the stickers are still blank. runAsync gives the
    // decode a real slice of time before the golden is taken.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(PlateView),
      matchesGoldenFile('goldens/${spec.id.replaceAll('.', '_')}.png'),
    );

    // Unmount the tree before disposing: _PlateCanvasState.dispose() calls
    // controller.detach(), which notifies listeners, so the controller must
    // still be live when the element tree tears down.
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  }

  group('shape', () {
    testWidgets(
      'the common one — two area letters, one identifier letter, four digits',
      (tester) async {
        await renderGolden(tester, spec: GermanPlates.car, values: 'DAX1953');
      },
    );

    testWidgets('the shortest — one of each', (tester) async {
      await renderGolden(
        tester,
        spec: GermanPlates.carFor(
          districtLetters: 1,
          group: GermanIdentifierGroup.a,
          digits: 1,
        ),
        values: 'NM4',
      );
    });

    testWidgets('the longest — three area letters and a group-c identifier', (
      tester,
    ) async {
      await renderGolden(
        tester,
        spec: GermanPlates.carFor(
          districtLetters: 3,
          group: GermanIdentifierGroup.c,
        ),
        values: 'CUXDP150',
      );
    });
  });

  group('variant', () {
    testWidgets('green — tax-exempt, and the rim goes green with the glyphs', (
      tester,
    ) async {
      await renderGolden(
        tester,
        spec: GermanPlates.greenFor(),
        values: 'DAX1953',
      );
    });

    testWidgets('H — historic, the suffix hard against the serial', (
      tester,
    ) async {
      await renderGolden(
        tester,
        spec: GermanPlates.historicFor(
          group: GermanIdentifierGroup.b,
          digits: 2,
        ),
        values: 'HLTL15',
      );
    });

    testWidgets('E — electric, at the eight-character maximum', (tester) async {
      await renderGolden(
        tester,
        spec: GermanPlates.electricFor(
          districtLetters: 3,
          group: GermanIdentifierGroup.b,
          digits: 2,
        ),
        values: 'LEROO39',
      );
    });

    testWidgets('seasonal — March to October, stacked over the rule', (
      tester,
    ) async {
      await renderGolden(
        tester,
        spec: GermanPlates.seasonalFor(),
        values: 'HRK19530310',
      );
    });

    testWidgets('06 — dealer, red, five digits and no identifier letters', (
      tester,
    ) async {
      await renderGolden(
        tester,
        spec: GermanPlates.dealerFor(),
        values: 'WÜ06131',
      );
    });

    testWidgets('07 — collector, red, the seal without an inspection sticker', (
      tester,
    ) async {
      await renderGolden(
        tester,
        spec: GermanPlates.collectorFor(districtLetters: 3),
        values: 'SDL07001',
      );
    });

    testWidgets(
      '04 — short-term, no euroband, the date stacked on the yellow band',
      (tester) async {
        await renderGolden(
          tester,
          spec: GermanPlates.shortTermFor(),
          values: 'KA04401090304',
        );
      },
    );

    testWidgets('export — the same plate with a red band', (tester) async {
      await renderGolden(
        tester,
        spec: GermanPlates.exportFor(districtLetters: 3),
        values: 'MKK04581090905',
      );
    });

    testWidgets('Bundeswehr — the flag block, the printed hyphen, six digits', (
      tester,
    ) async {
      await renderGolden(
        tester,
        spec: GermanPlates.bundeswehrFor(),
        values: 'Y751957',
      );
    });
  });
}
