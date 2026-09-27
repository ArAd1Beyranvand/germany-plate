import 'package:flutter/widgets.dart';
import 'package:core_plate/core_plate.dart';

import 'germany_alphabets.dart';
import 'german_plate_validator.dart';
import 'germany_country.dart';
import 'germany_identifier_group.dart';

/// The German plate designs.
class GermanPlates {
  const GermanPlates._();

  // Plate-space geometry, in the millimetres of a real 520x110 plate. The
  // character sizes are fixed by law (75mm tall; letters 47.5mm wide, digits
  // 44.5mm) and do not change with the number of characters — a plate with few
  // characters is a *shorter plate*, not a wider-tracked one. Everything below
  // therefore places cells at a constant pitch and lets the canvas end where
  // the last digit does.
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

  /// The season block: two stacked two-digit months, with a rule between them,
  /// printed at the right end of a seasonal plate. Half-height, because it has
  /// to fit two lines where the registration fits one.
  static const double _seasonGap = 14;
  static const double _seasonDigitWidth = 24, _seasonDigitPitch = 27, _seasonHeight = 40;
  static const double _seasonTop = 10, _seasonLowerTop = 60;
  static const double _seasonRuleTop = 53, _seasonRuleHeight = 4;

  /// The share of a slot's height the printed glyph actually occupies —
  /// `PlateTheme.glyphStyle`'s font size over the height it is handed.
  static const double _printedGlyphRatio = 0.72;

  /// A box for a [PlateLabel] that must sit on the same line as the slots
  /// beside it.
  ///
  /// A slot centres its character inside its box; a label is drawn from the top
  /// of its own. So a label handed a slot's box rides a third of a glyph too
  /// high — which on an `H` printed hard against the serial is the difference
  /// between a registration and a typo. Boxing the label to the glyph's real
  /// height and centring that box in the character line fixes it in data.
  static PlateBox _printedBox(double left, double width) {
    final height = _height * _printedGlyphRatio;
    return PlateBox(left, _top + (_height - height) / 2, width, height);
  }

  /// Where the area code starts on a plate with no euroband — the `04`,
  /// export and Bundeswehr formats. Clear of the rim, and nothing more.
  static const double _bareLeft = 20;

  /// The coloured band at the right-hand end of an `04` or export plate, and
  /// the six date digits stacked inside it.
  ///
  /// The band runs the full height of the face, corner to corner, and the date
  /// is three rows of two digits centred in it. Half-height rows, as with the
  /// season block: three lines have to fit where the registration fits one.
  static const double _bandGap = 12, _bandWidth = 62;
  static const double _bandDigitWidth = 22, _bandDigitPitch = 25;
  static const double _bandRowHeight = 28, _bandRowPitch = 31, _bandFirstRowTop = 10;

  /// The Bundeswehr plate: the flag block, the printed hyphen after the `Y`,
  /// and the gap that splits the six digits into two triples.
  static const double _flagPanelWidth = 46;
  static const double _flagGapAfter = 10;
  static const double _hyphenWidth = 30, _hyphenGapAfter = 10;
  static const double _tripleGap = 10;

  /// The inks a German plate is printed in, sampled from the reference photos
  /// in `claude/research/germany_plates/`.
  ///
  /// The rim follows the ink — a green plate has a green rim, a red one a red
  /// rim — which is what [PlateSpec.inkOverride] substitutes. Black is the
  /// theme's own and needs no constant.
  static const Color _greenInk = Color(0xFF1F6B2E);
  static const Color _redInk = Color(0xFFD42B1E);

  /// The two band fills, sampled from the same photos. These are not inks — a
  /// dated plate is printed black on white like an ordinary one, and the band
  /// is the coloured field the date sits on. See [PlateBand].
  static const Color _shortTermBand = Color(0xFFF0A800);
  static const Color _exportBand = Color(0xFFE62A22);

  /// Standard car plate: 2-letter area code, group-d identifier (1 letter, 4 digits).
  static final PlateSpec car = carFor();

  /// Car plate: area code of [districtLetters] letters + identifier of [group]'s
  /// shape with [digits] digits. Throws if invalid shape. [digits] defaults to group max.
  static PlateSpec carFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits);

  /// Car plate printed in green (tax-exempt vehicles). Takes same args as [carFor].
  static PlateSpec greenFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits, ink: _greenInk, idKind: 'green');

  /// Car plate with `H` suffix (classic vehicle). Same args as [carFor].
  static PlateSpec historicFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits, suffix: 'H', idKind: 'historic');

  /// Car plate with `E` suffix (electric vehicle, 2015 Electric Mobility Act).
  static PlateSpec electricFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits, suffix: 'E', idKind: 'electric');

  /// Car plate with validity months (slots) at right: first above rule, last below.
  /// No order required (11–03 is valid). Same args as [carFor].
  static PlateSpec seasonalFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits, season: true, idKind: 'seasonal');

  /// Dealer plate (`06`): red on white, area code + 5 digits starting 06.
  /// Not a registration. Not judged by [GermanPlateValidator].
  static PlateSpec dealerFor({int districtLetters = 2}) =>
      _serialPlate(kind: 'dealer', districtLetters: districtLetters);

  /// Collector plate (`07`): red on white, area code + 5 digits starting 07.
  /// Usable across multiple vehicles. No inspection sticker. Not judged by validator.
  static PlateSpec collectorFor({int districtLetters = 2}) =>
      _serialPlate(kind: 'collector', districtLetters: districtLetters, inspectionSticker: false);

  static PlateSpec _serialPlate({required String kind, required int districtLetters, bool inspectionSticker = true}) {
    if (districtLetters < 1 || districtLetters > 3) {
      throw ArgumentError.value(districtLetters, 'districtLetters', 'An area code carries one, two or three letters');
    }
    return _plate(
      id: 'de.$kind${districtLetters == 2 ? '' : '.$districtLetters'}',
      districtLetters: districtLetters,
      identifierLetters: 0,
      serialDigits: 5,
      ink: _redInk,
      inspectionSticker: inspectionSticker,
    );
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

    if (districtLetters < 1 || districtLetters > 3) {
      throw ArgumentError.value(districtLetters, 'districtLetters', 'An area code carries one, two or three letters');
    }
    if (!group.admitsDigits(serialDigits)) {
      throw ArgumentError.value(
        serialDigits,
        'digits',
        'Group ${group.name} is issued with ${group.minDigits}-${group.maxDigits} digits',
      );
    }
    final total = districtLetters + group.letters + serialDigits + (suffix == null ? 0 : 1);
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
    final districtRight = _districtLeft + (districtLetters - 1) * _letterPitch + _letterWidth;
    final decalLeft = districtRight + _decalGapBefore;
    final identifierLeft = decalLeft + _decalSize + _decalGapAfter;
    final identifierRight = identifierLetters == 0
        ? identifierLeft - _serialGap
        : identifierLeft + (identifierLetters - 1) * _letterPitch + _letterWidth;
    final serialLeft = identifierRight + _serialGap;
    final serialRight = serialLeft + (serialDigits - 1) * _digitPitch + _digitWidth;
    final charactersRight = suffix == null ? serialRight : serialRight + _letterWidth;
    final seasonLeft = charactersRight + _seasonGap;
    final seasonRight = seasonLeft + _seasonDigitPitch + _seasonDigitWidth;
    final contentRight = season ? seasonRight : charactersRight;

    final firstIdentifier = districtLetters;
    final firstSerial = firstIdentifier + identifierLetters;
    final firstSeason = firstSerial + serialDigits;

    return PlateSpec(
      id: id,
      country: GermanyCountry.germany,
      inkOverride: ink,
      canvasWidth: contentRight + _rightMargin,
      canvasHeight: 110,
      panel: const PlatePanel(box: PlateBox(0, 0, 56.4, 110)),
      textDirection: TextDirection.ltr,
      slots: [
        ...plateRegister(
          alphabet: GermanAlphabets.districtLetters,
          count: districtLetters,
          left: _districtLeft,
          top: _top,
          width: _letterWidth,
          height: _height,
          pitch: _letterPitch,
        ),
        ...plateRegister(
          alphabet: PlateAlphabet.latinUppercase,
          count: identifierLetters,
          left: identifierLeft,
          top: _top,
          width: _letterWidth,
          height: _height,
          pitch: _letterPitch,
        ),
        ...plateRegister(
          alphabet: PlateAlphabet.latinDigits,
          count: serialDigits,
          left: serialLeft,
          top: _top,
          width: _digitWidth,
          height: _height,
          pitch: _digitPitch,
        ),
        if (season) ...[
          ...plateRegister(
            alphabet: PlateAlphabet.latinDigits,
            count: 2,
            left: seasonLeft,
            top: _seasonTop,
            width: _seasonDigitWidth,
            height: _seasonHeight,
            pitch: _seasonDigitPitch,
          ),
          ...plateRegister(
            alphabet: PlateAlphabet.latinDigits,
            count: 2,
            left: seasonLeft,
            top: _seasonLowerTop,
            width: _seasonDigitWidth,
            height: _seasonHeight,
            pitch: _seasonDigitPitch,
          ),
        ],
      ],
      rules: [
        if (season) PlateRule(box: PlateBox(seasonLeft, _seasonRuleTop, seasonRight - seasonLeft, _seasonRuleHeight)),
      ],
      decals: [
        if (inspectionSticker)
          PlateDecal(
            image: const AssetImage('assets/de_inspection_sticker.png', package: 'germany_plate'),
            box: PlateBox(decalLeft, 14, _decalSize, _decalSize),
          ),
        PlateDecal(
          image: const AssetImage('assets/de_state_seal.png', package: 'germany_plate'),
          box: PlateBox(decalLeft, inspectionSticker ? 54 : 36, _decalSize, _decalSize),
        ),
      ],
      labels: [
        if (suffix != null) PlateLabel(text: suffix, box: _printedBox(serialRight, _letterWidth), glyphHeight: _height),
      ],
      textGroups: [
        PlateTextGroup([for (var i = 0; i < districtLetters; i++) i], key: 'district'),
        PlateTextGroup([for (var i = 0; i < identifierLetters; i++) firstIdentifier + i], key: 'letters'),
        PlateTextGroup([for (var i = 0; i < serialDigits; i++) firstSerial + i], key: 'serial'),
        if (season) ...[
          PlateTextGroup([firstSeason, firstSeason + 1], key: 'seasonStart'),
          PlateTextGroup([firstSeason + 2, firstSeason + 3], key: 'seasonEnd'),
        ],
      ],
    );
  }

  /// Suffix for [spec] ('H' historic, 'E' electric, or ''). Not in [PlateSpec.slots].
  static String suffixOf(PlateSpec spec) {
    for (final MapEntry(key: kind, value: suffix) in _suffixKinds.entries) {
      if (spec.id.startsWith('de.car.$kind')) return suffix;
    }
    return '';
  }

  static const Map<String, String> _suffixKinds = {'historic': 'H', 'electric': 'E'};

  /// True if [spec] carries season months (checks textGroups, not id).
  static bool isSeasonal(PlateSpec spec) => spec.textGroups.any((group) => group.key == 'seasonStart');

  /// All legal car shapes in stable order.
  static final List<PlateSpec> allCars = List<PlateSpec>.unmodifiable(<PlateSpec>[
    for (final shape in _shapes) carFor(districtLetters: shape.$1, group: shape.$2, digits: shape.$3),
  ]);

  /// Car variants: green, seasonal, historic, electric. Separate from [allCars].
  static final List<PlateSpec> allCarVariants = List<PlateSpec>.unmodifiable(<PlateSpec>[
    for (final (districtLetters, group, digits) in _shapes) ...[
      greenFor(districtLetters: districtLetters, group: group, digits: digits),
      seasonalFor(districtLetters: districtLetters, group: group, digits: digits),
      if (districtLetters + group.letters + digits < 8) ...[
        historicFor(districtLetters: districtLetters, group: group, digits: digits),
        electricFor(districtLetters: districtLetters, group: group, digits: digits),
      ],
    ],
  ]);

  /// Non-registration `06` and `07` serial plates. Not judged by [GermanPlateValidator].
  static final List<PlateSpec> allSerialPlates = List<PlateSpec>.unmodifiable(<PlateSpec>[
    for (var districtLetters = 1; districtLetters <= 3; districtLetters++) ...[
      dealerFor(districtLetters: districtLetters),
      collectorFor(districtLetters: districtLetters),
    ],
  ]);

  /// Non-registration `04` and export plates with expiry dates. Not judged by validator.
  static final List<PlateSpec> allDatedPlates = List<PlateSpec>.unmodifiable(<PlateSpec>[
    for (var districtLetters = 1; districtLetters <= 3; districtLetters++) ...[
      shortTermFor(districtLetters: districtLetters),
      exportFor(districtLetters: districtLetters),
    ],
  ]);

  /// Validator for [spec]. Non-registrations get serial/dated validators.
  static PlateValidator validatorFor(PlateSpec spec) => switch (spec.id) {
    final id when id.startsWith('de.dealer') => const GermanSerialPlateValidator.dealer(),
    final id when id.startsWith('de.collector') => const GermanSerialPlateValidator.collector(),
    final id when id.startsWith('de.shortterm') => const GermanDatedPlateValidator.shortTerm(),
    final id when id.startsWith('de.export') => const GermanDatedPlateValidator.export(),
    final id when id.startsWith('de.bundeswehr') => const GermanBundeswehrValidator(),
    _ => const GermanPlateValidator(),
  };

  /// Short-term plate (`04`): black on white + yellow band with DD/MM/YY expiry.
  static PlateSpec shortTermFor({int districtLetters = 2}) =>
      _rightBandPlate(kind: 'shortterm', districtLetters: districtLetters, band: _shortTermBand);

  /// Export plate (`Ausfuhrkennzeichen`): like short-term but red band instead.
  static PlateSpec exportFor({int districtLetters = 2}) =>
      _rightBandPlate(kind: 'export', districtLetters: districtLetters, band: _exportBand);

  static PlateSpec _rightBandPlate({required String kind, required int districtLetters, required Color band}) {
    if (districtLetters < 1 || districtLetters > 3) {
      throw ArgumentError.value(districtLetters, 'districtLetters', 'An area code carries one, two or three letters');
    }

    const serialDigits = 5;
    final districtRight = _bareLeft + (districtLetters - 1) * _letterPitch + _letterWidth;
    final decalLeft = districtRight + _decalGapBefore;
    final serialLeft = decalLeft + _decalSize + _decalGapAfter;
    final serialRight = serialLeft + (serialDigits - 1) * _digitPitch + _digitWidth;
    final bandLeft = serialRight + _bandGap;
    final canvasWidth = bandLeft + _bandWidth;
    final dateLeft = bandLeft + (_bandWidth - (_bandDigitPitch + _bandDigitWidth)) / 2;

    final firstDate = districtLetters + serialDigits;

    return PlateSpec(
      id: 'de.$kind${districtLetters == 2 ? '' : '.$districtLetters'}',
      country: GermanyCountry.germany,
      canvasWidth: canvasWidth,
      canvasHeight: 110,
      noPanel: true,
      panel: const PlatePanel(box: PlateBox(0, 0, 0, 110)),
      rightBand: PlateBand(box: PlateBox(bandLeft, 0, _bandWidth, 110), color: band),
      textDirection: TextDirection.ltr,
      slots: [
        ...plateRegister(
          alphabet: GermanAlphabets.districtLetters,
          count: districtLetters,
          left: _bareLeft,
          top: _top,
          width: _letterWidth,
          height: _height,
          pitch: _letterPitch,
        ),
        ...plateRegister(
          alphabet: PlateAlphabet.latinDigits,
          count: serialDigits,
          left: serialLeft,
          top: _top,
          width: _digitWidth,
          height: _height,
          pitch: _digitPitch,
        ),
        for (var row = 0; row < 3; row++)
          ...plateRegister(
            alphabet: PlateAlphabet.latinDigits,
            count: 2,
            left: dateLeft,
            top: _bandFirstRowTop + row * _bandRowPitch,
            width: _bandDigitWidth,
            height: _bandRowHeight,
            pitch: _bandDigitPitch,
          ),
      ],
      decals: [
        PlateDecal(
          image: const AssetImage('assets/de_state_seal.png', package: 'germany_plate'),
          box: PlateBox(decalLeft, 36, _decalSize, _decalSize),
        ),
      ],
      textGroups: [
        PlateTextGroup([for (var i = 0; i < districtLetters; i++) i], key: 'district'),
        PlateTextGroup([for (var i = 0; i < serialDigits; i++) districtLetters + i], key: 'serial'),
        PlateTextGroup([firstDate, firstDate + 1], key: 'expiryDay'),
        PlateTextGroup([firstDate + 2, firstDate + 3], key: 'expiryMonth'),
        PlateTextGroup([firstDate + 4, firstDate + 5], key: 'expiryYear'),
      ],
    );
  }

  /// Bundeswehr plate: flag (no euroband) + `Y` + hyphen + 6 digits in two triples.
  /// No inspection sticker. [GermanBundeswehrValidator] enforces the `Y`.
  static PlateSpec bundeswehrFor({int districtLetters = 1}) {
    if (districtLetters < 1 || districtLetters > 3) {
      throw ArgumentError.value(districtLetters, 'districtLetters', 'An area code carries one, two or three letters');
    }

    final districtLeft = _flagPanelWidth + _flagGapAfter;
    final districtRight = districtLeft + (districtLetters - 1) * _letterPitch + _letterWidth;
    final hyphenRight = districtRight + _hyphenWidth;
    final serialLeft = hyphenRight + _hyphenGapAfter;
    final firstTripleRight = serialLeft + 2 * _digitPitch + _digitWidth;
    final secondTripleLeft = firstTripleRight + _tripleGap;
    final secondTripleRight = secondTripleLeft + 2 * _digitPitch + _digitWidth;

    final firstSerial = districtLetters;

    return PlateSpec(
      id: 'de.bundeswehr${districtLetters == 1 ? '' : '.$districtLetters'}',
      // The flag block, not the blue EU panel — see [GermanyCountry.bundeswehr].
      country: GermanyCountry.bundeswehr,
      canvasWidth: secondTripleRight + _rightMargin,
      canvasHeight: 110,
      panel: const PlatePanel(
        box: PlateBox(0, 0, _flagPanelWidth, 110),
        padding: EdgeInsets.symmetric(horizontal: 3.5, vertical: 21),
      ),
      textDirection: TextDirection.ltr,
      slots: [
        ...plateRegister(
          alphabet: GermanAlphabets.districtLetters,
          count: districtLetters,
          left: districtLeft,
          top: _top,
          width: _letterWidth,
          height: _height,
          pitch: _letterPitch,
        ),
        ...plateRegister(
          alphabet: PlateAlphabet.latinDigits,
          count: 3,
          left: serialLeft,
          top: _top,
          width: _digitWidth,
          height: _height,
          pitch: _digitPitch,
        ),
        ...plateRegister(
          alphabet: PlateAlphabet.latinDigits,
          count: 3,
          left: secondTripleLeft,
          top: _top,
          width: _digitWidth,
          height: _height,
          pitch: _digitPitch,
        ),
      ],
      decals: [
        PlateDecal(
          image: const AssetImage('assets/de_state_seal.png', package: 'germany_plate'),
          box: PlateBox(districtRight, 60, _decalSize, _decalSize),
        ),
      ],
      labels: [PlateLabel(text: '-', box: _printedBox(districtRight, _hyphenWidth), glyphHeight: _height)],
      textGroups: [
        PlateTextGroup([for (var i = 0; i < districtLetters; i++) i], key: 'district'),
        PlateTextGroup([firstSerial, firstSerial + 1, firstSerial + 2], key: 'serial'),
        PlateTextGroup([firstSerial + 3, firstSerial + 4, firstSerial + 5], key: 'serialTail'),
      ],
    );
  }

  /// Every spec this package declares.
  static final List<PlateSpec> allSpecs = List<PlateSpec>.unmodifiable(<PlateSpec>[
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
          if (districtLetters + group.letters + digits <= 8) (districtLetters, group, digits),
  ];

  static String _idFor(int districtLetters, GermanIdentifierGroup group, int digits, String? kind) {
    final shape = districtLetters == 2 && group == GermanIdentifierGroup.d && digits == 4
        ? ''
        : '.$districtLetters-${group.letters}-$digits';
    return kind == null ? 'de.car$shape' : 'de.car.$kind$shape';
  }
}
