import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'germany_alphabets.dart';
import 'german_plate_validator.dart';
import 'germany_country.dart';
import 'germany_identifier_group.dart';
import 'germany_regions.dart';

class GermanPlates {
  const GermanPlates._();

  // Plate-space geometry, in the millimetres of a real 520x110 plate. Character
  // sizes are fixed by law and do not vary with the character count: a plate
  // with few characters is a shorter plate, not a wider-tracked one. Cells sit
  // at a constant pitch and the canvas ends where the last cell does.
  static const double _top = 17, _height = 76;
  static const double _letterWidth = 52, _letterPitch = 58;
  static const double _digitWidth = 46, _digitPitch = 50;

  /// Where the area code starts: clear of the EU panel, which ends at 56.4.
  static const double _districtLeft = 64;

  /// The round stickers, and the gaps on either side of them.
  static const double _decalSize = 38, _decalGapBefore = 10, _decalGapAfter = 8;

  /// Between the identifier's letters and its digits.
  static const double _serialGap = 6;

  /// Blank plate to the right of the last digit.
  static const double _rightMargin = 36;

  /// The season block: two stacked two-digit months with a rule between,
  /// at half height so two lines fit where the registration fits one.
  static const double _seasonGap = 14;
  static const double _seasonDigitWidth = 24,
      _seasonDigitPitch = 27,
      _seasonHeight = 40;
  static const double _seasonTop = 10, _seasonLowerTop = 60;
  static const double _seasonRuleTop = 53, _seasonRuleHeight = 4;

  /// The share of a slot's height the printed glyph actually occupies —
  /// `PlateTheme.glyphStyle`'s font size over the height it is handed.
  static const double _printedGlyphRatio = 0.72;

  /// A box for a [PlateLabel] on the same line as the slots beside it.
  ///
  /// A slot centres its character in its box but a label is drawn from the top
  /// of its own, so a label given a slot's box rides too high. This boxes the
  /// label to the glyph's real height, centred in the character line.
  static PlateBox _printedBox(double left, double width) {
    final height = _height * _printedGlyphRatio;
    return PlateBox(left, _top + (_height - height) / 2, width, height);
  }

  /// Where the area code starts on a plate with no euroband.
  static const double _bareLeft = 20;

  /// The full-height band at the right end of an `04` or export plate, with
  /// the date as three half-height rows of two digits centred in it.
  static const double _bandGap = 12, _bandWidth = 62;
  static const double _bandDigitWidth = 22, _bandDigitPitch = 25;
  static const double _bandRowHeight = 28,
      _bandRowPitch = 31,
      _bandFirstRowTop = 10;

  static const double _flagPanelWidth = 46, _flagGapAfter = 10;
  static const double _hyphenWidth = 30, _hyphenGapAfter = 10, _tripleGap = 10;

  /// Inks sampled from reference photos. The rim follows the ink, which is what
  /// [PlateSpec.inkOverride] substitutes. Black is the theme's own.
  static const Color _greenInk = Color(0xFF1F6B2E);
  static const Color _redInk = Color(0xFFD42B1E);

  /// Band fills, not inks: a dated plate is printed black on white and the
  /// band is the field the date sits on.
  static const Color _shortTermBand = Color(0xFFF0A800);
  static const Color _exportBand = Color(0xFFE62A22);

  static const AssetImage _stateSeal = AssetImage(
    'assets/de_state_seal.png',
    package: 'germany_plate',
  );

  /// Standard car plate: 2-letter area code, group-d identifier (1 letter, 4 digits).
  static final PlateSpec car = carFor();

  /// Car plate: area code of [districtLetters] letters + identifier of [group]'s
  /// shape with [digits] digits. Throws if invalid shape. [digits] defaults to group max.
  static PlateSpec carFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) =>
      _carLike(districtLetters: districtLetters, group: group, digits: digits);

  /// Car plate printed in green (tax-exempt vehicles). Takes same args as [carFor].
  static PlateSpec greenFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(
    districtLetters: districtLetters,
    group: group,
    digits: digits,
    ink: _greenInk,
    idKind: 'green',
  );

  /// Car plate with `H` suffix (classic vehicle). Same args as [carFor].
  static PlateSpec historicFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(
    districtLetters: districtLetters,
    group: group,
    digits: digits,
    suffix: 'H',
    idKind: 'historic',
  );

  /// Car plate with `E` suffix (electric vehicle).
  static PlateSpec electricFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(
    districtLetters: districtLetters,
    group: group,
    digits: digits,
    suffix: 'E',
    idKind: 'electric',
  );

  /// Car plate with season months at right, start above the rule, end below.
  /// Same args as [carFor].
  static PlateSpec seasonalFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(
    districtLetters: districtLetters,
    group: group,
    digits: digits,
    season: true,
    idKind: 'seasonal',
  );

  /// Dealer plate (`06`): red on white, area code + 5 digits starting 06.
  /// Not a registration. Not judged by [GermanPlateValidator].
  static PlateSpec dealerFor({int districtLetters = 2}) =>
      _serialPlate(kind: 'dealer', districtLetters: districtLetters);

  /// Collector plate (`07`): red on white, area code + 5 digits starting 07.
  /// Usable across multiple vehicles. No inspection sticker. Not judged by validator.
  static PlateSpec collectorFor({int districtLetters = 2}) => _serialPlate(
    kind: 'collector',
    districtLetters: districtLetters,
    inspectionSticker: false,
  );

  static PlateSpec _serialPlate({
    required String kind,
    required int districtLetters,
    bool inspectionSticker = true,
  }) {
    _checkDistrictLetters(districtLetters);
    return _plate(
      id: 'de.$kind${districtLetters == 2 ? '' : '.$districtLetters'}',
      districtLetters: districtLetters,
      identifierLetters: 0,
      serialDigits: 5,
      ink: _redInk,
      inspectionSticker: inspectionSticker,
    );
  }

  static void _checkDistrictLetters(int districtLetters) {
    if (districtLetters < 1 || districtLetters > 3) {
      throw ArgumentError.value(
        districtLetters,
        'districtLetters',
        'An area code carries one, two or three letters',
      );
    }
  }

  static PlateSpec _carLike({
    required int districtLetters,
    required GermanIdentifierGroup group,
    required int? digits,
    Color? ink,
    String? suffix,
    String? idKind,
    bool season = false,
  }) {
    final serialDigits = digits ?? group.maxDigits;

    _checkDistrictLetters(districtLetters);
    if (!group.admitsDigits(serialDigits)) {
      throw ArgumentError.value(
        serialDigits,
        'digits',
        'Group ${group.name} is issued with ${group.minDigits}-${group.maxDigits} digits',
      );
    }
    final total =
        districtLetters +
        group.letters +
        serialDigits +
        (suffix == null ? 0 : 1);
    if (total > 8) {
      throw ArgumentError(
        'A $districtLetters-letter area code with a group-${group.name} '
        'identifier${suffix == null ? '' : ' and a "$suffix" suffix'} is $total '
        'characters; a plate may carry at most eight.',
      );
    }

    return _plate(
      id: _idFor(districtLetters, group, serialDigits, idKind),
      districtLetters: districtLetters,
      identifierLetters: group.letters,
      serialDigits: serialDigits,
      ink: ink,
      suffix: suffix,
      season: season,
    );
  }

  static PlateSpec _plate({
    required String id,
    required int districtLetters,
    required int identifierLetters,
    required int serialDigits,
    Color? ink,
    String? suffix,
    bool inspectionSticker = true,
    bool season = false,
  }) {
    final PlateBox printed = _printedBox(0, _letterWidth);
    PlateRowCells seasonCells(double top, String group) => PlateRowCells(
      PlateAlphabet.latinDigits,
      2,
      cellWidth: _seasonDigitWidth,
      pitch: _seasonDigitPitch,
      top: top,
      height: _seasonHeight,
      group: group,
    );
    final List<PlateRowItem> items = <PlateRowItem>[
      _letters(GermanAlphabets.districtLetters, districtLetters, 'district'),
      const PlateRowGap(_decalGapBefore),
      const PlateRowGap(_decalSize), // the stickers
      const PlateRowGap(_decalGapAfter),
      if (identifierLetters > 0) ...<PlateRowItem>[
        _letters(PlateAlphabet.latinUppercase, identifierLetters, 'letters'),
        const PlateRowGap(_serialGap),
      ],
      _digits(serialDigits, 'serial'),
      if (suffix != null)
        PlateRowText.styled(
          suffix,
          _letterWidth,
          top: printed.top,
          height: printed.height,
          glyphHeight: _height,
        ),
      if (season) ...<PlateRowItem>[
        const PlateRowGap(_seasonGap),
        seasonCells(_seasonTop, 'seasonStart'),
      ],
    ];
    final PlateRowLayout row = plateRow(
      items,
      left: _districtLeft,
      top: _top,
      height: _height,
      pitch: _letterPitch,
    );
    final double decalLeft = row.lefts[2];
    final double seasonLeft = row.lefts.last;

    return PlateSpec(
      id: id,
      country: GermanyCountry.germany,
      inkOverride: ink,
      canvasWidth: row.right + _rightMargin,
      canvasHeight: 110,
      panel: const PlatePanel(box: PlateBox(0, 0, 56.4, 110)),
      background: const PlateSection.columns([
        PlatePart(PlateSection.fill(PlateFill.panel), end: 56.4),
        PlatePart(PlateSection.plain),
      ]),
      textDirection: TextDirection.ltr,
      slots: [
        ...row.slots,
        if (season)
          ...plateRow(
            [seasonCells(_seasonLowerTop, 'seasonEnd')],
            left: seasonLeft,
            top: _top,
            height: _height,
            pitch: _letterPitch,
          ).slots,
      ],
      rules: [
        if (season)
          PlateRule(
            box: PlateBox.fromLTRB(
              seasonLeft,
              _seasonRuleTop,
              row.right,
              _seasonRuleTop + _seasonRuleHeight,
            ),
          ),
      ],
      decals: [
        if (inspectionSticker)
          PlateDecal(
            image: const AssetImage(
              'assets/de_inspection_sticker.png',
              package: 'germany_plate',
            ),
            box: PlateBox(decalLeft, 14, _decalSize, _decalSize),
          ),
        PlateDecal(
          image: _stateSeal,
          box: PlateBox(
            decalLeft,
            inspectionSticker ? 54 : 36,
            _decalSize,
            _decalSize,
          ),
        ),
      ],
      labels: row.labels,
      resolveRegion: GermanyRegions.captionOf,
    );
  }

  /// [count] letter cells at the letter pitch, keyed [group].
  static PlateRowCells _letters(PlateAlphabet a, int count, String group) =>
      PlateRowCells(a, count, cellWidth: _letterWidth, group: group);

  /// [count] digit cells at the digit pitch, keyed [group].
  static PlateRowCells _digits(int count, String group) => PlateRowCells(
    PlateAlphabet.latinDigits,
    count,
    cellWidth: _digitWidth,
    pitch: _digitPitch,
    group: group,
  );

  /// Suffix for [spec] ('H' historic, 'E' electric, or ''). Not in [PlateSpec.slots].
  static String suffixOf(PlateSpec spec) {
    for (final MapEntry(key: kind, value: suffix) in _suffixKinds.entries) {
      if (spec.id.startsWith('de.car.$kind')) return suffix;
    }
    return '';
  }

  static const Map<String, String> _suffixKinds = {
    'historic': 'H',
    'electric': 'E',
  };

  /// True if [spec] carries season months (checks textGroups, not id).
  static bool isSeasonal(PlateSpec spec) =>
      spec.textGroups.any((group) => group.key == 'seasonStart');

  /// All legal car shapes in stable order.
  static final List<PlateSpec> allCars =
      List<PlateSpec>.unmodifiable(<PlateSpec>[
        for (final shape in _shapes)
          carFor(districtLetters: shape.$1, group: shape.$2, digits: shape.$3),
      ]);

  /// Car variants: green, seasonal, historic, electric. Separate from [allCars].
  static final List<PlateSpec> allCarVariants = List<PlateSpec>.unmodifiable(
    <PlateSpec>[
      for (final (districtLetters, group, digits) in _shapes) ...[
        greenFor(
          districtLetters: districtLetters,
          group: group,
          digits: digits,
        ),
        seasonalFor(
          districtLetters: districtLetters,
          group: group,
          digits: digits,
        ),
        if (districtLetters + group.letters + digits < 8) ...[
          historicFor(
            districtLetters: districtLetters,
            group: group,
            digits: digits,
          ),
          electricFor(
            districtLetters: districtLetters,
            group: group,
            digits: digits,
          ),
        ],
      ],
    ],
  );

  /// Non-registration `06` and `07` serial plates. Not judged by [GermanPlateValidator].
  static final List<PlateSpec> allSerialPlates = List<PlateSpec>.unmodifiable(
    <PlateSpec>[
      for (
        var districtLetters = 1;
        districtLetters <= 3;
        districtLetters++
      ) ...[
        dealerFor(districtLetters: districtLetters),
        collectorFor(districtLetters: districtLetters),
      ],
    ],
  );

  /// Non-registration `04` and export plates with expiry dates. Not judged by validator.
  static final List<PlateSpec> allDatedPlates = List<PlateSpec>.unmodifiable(
    <PlateSpec>[
      for (
        var districtLetters = 1;
        districtLetters <= 3;
        districtLetters++
      ) ...[
        shortTermFor(districtLetters: districtLetters),
        exportFor(districtLetters: districtLetters),
      ],
    ],
  );

  /// Validator for [spec]. Non-registrations get serial/dated validators.
  static PlateValidator validatorFor(PlateSpec spec) => switch (spec.id) {
    final id when id.startsWith('de.dealer') =>
      const GermanSerialPlateValidator.dealer(),
    final id when id.startsWith('de.collector') =>
      const GermanSerialPlateValidator.collector(),
    final id when id.startsWith('de.shortterm') =>
      const GermanDatedPlateValidator.shortTerm(),
    final id when id.startsWith('de.export') =>
      const GermanDatedPlateValidator.export(),
    final id when id.startsWith('de.bundeswehr') =>
      const GermanBundeswehrValidator(),
    _ => const GermanPlateValidator(),
  };

  /// Short-term plate (`04`): black on white + yellow band with DD/MM/YY expiry.
  static PlateSpec shortTermFor({int districtLetters = 2}) => _rightBandPlate(
    kind: 'shortterm',
    districtLetters: districtLetters,
    band: _shortTermBand,
  );

  /// Export plate (`Ausfuhrkennzeichen`): like short-term but red band instead.
  static PlateSpec exportFor({int districtLetters = 2}) => _rightBandPlate(
    kind: 'export',
    districtLetters: districtLetters,
    band: _exportBand,
  );

  static PlateSpec _rightBandPlate({
    required String kind,
    required int districtLetters,
    required Color band,
  }) {
    _checkDistrictLetters(districtLetters);
    final PlateRowLayout row = plateRow(
      <PlateRowItem>[
        _letters(GermanAlphabets.districtLetters, districtLetters, 'district'),
        const PlateRowGap(_decalGapBefore),
        const PlateRowGap(_decalSize), // the seal
        const PlateRowGap(_decalGapAfter),
        _digits(5, 'serial'),
        const PlateRowGap(_bandGap),
      ],
      left: _bareLeft,
      top: _top,
      height: _height,
      pitch: _letterPitch,
    );
    final double decalLeft = row.lefts[2], bandLeft = row.right;
    final double dateCentre = bandLeft + _bandWidth / 2;

    return PlateSpec(
      id: 'de.$kind${districtLetters == 2 ? '' : '.$districtLetters'}',
      country: GermanyCountry.germany,
      canvasWidth: bandLeft + _bandWidth,
      canvasHeight: 110,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, 110)),
      // The band is the plate's last column, run out under the frame.
      background: PlateSection.columns([
        PlatePart(PlateSection.plain, end: bandLeft),
        PlatePart(PlateSection.fill(PlateFill.color(band))),
      ]),
      textDirection: TextDirection.ltr,
      slots: [
        ...row.slots,
        for (final (int r, String key) in const [
          (0, 'expiryDay'),
          (1, 'expiryMonth'),
          (2, 'expiryYear'),
        ])
          ...plateRow(
            [
              PlateRowCells(
                PlateAlphabet.latinDigits,
                2,
                cellWidth: _bandDigitWidth,
                pitch: _bandDigitPitch,
                group: key,
              ),
            ],
            centre: dateCentre,
            top: _bandFirstRowTop + r * _bandRowPitch,
            height: _bandRowHeight,
            pitch: _bandDigitPitch,
          ).slots,
      ],
      decals: [
        PlateDecal(
          image: _stateSeal,
          box: PlateBox(decalLeft, 36, _decalSize, _decalSize),
        ),
      ],
      resolveRegion: GermanyRegions.captionOf,
    );
  }

  /// Bundeswehr plate: flag (no euroband) + `Y` + hyphen + 6 digits in two triples.
  /// No inspection sticker. [GermanBundeswehrValidator] enforces the `Y`.
  static PlateSpec bundeswehrFor({int districtLetters = 1}) {
    _checkDistrictLetters(districtLetters);
    final PlateBox printed = _printedBox(0, _hyphenWidth);
    final PlateRowLayout row = plateRow(
      <PlateRowItem>[
        _letters(GermanAlphabets.districtLetters, districtLetters, 'district'),
        PlateRowText.styled(
          '-',
          _hyphenWidth,
          top: printed.top,
          height: printed.height,
          glyphHeight: _height,
        ),
        const PlateRowGap(_hyphenGapAfter),
        _digits(3, 'serial'),
        const PlateRowGap(_tripleGap),
        _digits(3, 'serialTail'),
      ],
      left: _flagPanelWidth + _flagGapAfter,
      top: _top,
      height: _height,
      pitch: _letterPitch,
    );

    return PlateSpec(
      id: 'de.bundeswehr${districtLetters == 1 ? '' : '.$districtLetters'}',
      country: GermanyCountry.bundeswehr,
      canvasWidth: row.right + _rightMargin,
      canvasHeight: 110,
      panel: const PlatePanel(
        box: PlateBox(0, 0, _flagPanelWidth, 110),
        padding: EdgeInsets.symmetric(horizontal: 3.5, vertical: 21),
      ),
      background: const PlateSection.columns([
        PlatePart(PlateSection.fill(PlateFill.panel), end: _flagPanelWidth),
        PlatePart(PlateSection.plain),
      ]),
      textDirection: TextDirection.ltr,
      slots: row.slots,
      decals: [
        PlateDecal(
          image: _stateSeal,
          box: PlateBox(row.lefts[1], 60, _decalSize, _decalSize),
        ),
      ],
      labels: row.labels,
    );
  }

  /// Every spec this package declares.
  static final List<PlateSpec> allSpecs =
      List<PlateSpec>.unmodifiable(<PlateSpec>[
        ...allCars,
        ...allCarVariants,
        ...allSerialPlates,
        ...allDatedPlates,
        bundeswehrFor(),
      ]);

  /// Legal (area-code length, group, serial length) tuples in stable order.
  static final List<(int, GermanIdentifierGroup, int)> _shapes = [
    for (var districtLetters = 1; districtLetters <= 3; districtLetters++)
      for (final group in GermanIdentifierGroup.values)
        for (var digits = group.minDigits; digits <= group.maxDigits; digits++)
          if (districtLetters + group.letters + digits <= 8)
            (districtLetters, group, digits),
  ];

  static String _idFor(
    int districtLetters,
    GermanIdentifierGroup group,
    int digits,
    String? kind,
  ) {
    final shape =
        districtLetters == 2 && group == GermanIdentifierGroup.d && digits == 4
        ? ''
        : '.$districtLetters-${group.letters}-$digits';
    return kind == null ? 'de.car$shape' : 'de.car.$kind$shape';
  }
}
