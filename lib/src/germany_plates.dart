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

  /// A standard German car plate (e.g. "DA·X1953") in its most common shape:
  /// a two-letter area code and a group-d identifier (one letter, four digits).
  ///
  /// Kept as a named const-like entry point because it is what nearly every
  /// caller wants and what the golden pins; [carFor] builds every other legal
  /// shape, and `carFor()` with no arguments returns exactly this spec.
  static final PlateSpec car = carFor();

  /// The car plate for a given shape: an area code of [districtLetters]
  /// letters and an identifier of [group]'s shape carrying [digits] digits.
  ///
  /// The real format is an area code of one, two or three letters followed by
  /// an identifier of one or two letters and one to four digits, capped at
  /// eight characters overall. Rather than take three free integers and hope,
  /// this takes the [GermanIdentifierGroup] the law actually issues, so a
  /// letter/digit pairing that no authority hands out cannot be asked for. The
  /// remaining ways to get it wrong — a four-letter area code, a group-e
  /// identifier behind a three-letter code — throw.
  ///
  /// [digits] defaults to the group's maximum, which makes `carFor()` the
  /// familiar two-letter, one-letter, four-digit plate.
  ///
  /// Throws [ArgumentError] rather than asserting: this is public API, and an
  /// assert is stripped from the release build that would render the malformed
  /// plate.
  static PlateSpec carFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits);

  /// The same plate printed in green: a vehicle exempt from vehicle tax —
  /// an ambulance, a tractor, an agricultural or boat trailer.
  ///
  /// Only the ink changes. The blue EU band stays blue, the shape is a
  /// standard one, and the validator's rules all still apply, which is why this
  /// takes the same arguments as [carFor] rather than being its own format.
  static PlateSpec greenFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits, ink: _greenInk, idKind: 'green');

  /// A classic vehicle's plate: the standard plate with an `H` for *historisch*
  /// printed after the serial (e.g. "K-AA 100H").
  ///
  /// Requires a first registration at least 30 years ago and a preservation-
  /// worthy condition, and carries a flat annual tax.
  static PlateSpec historicFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits, suffix: 'H', idKind: 'historic');

  /// A plug-in electric vehicle's plate: the standard plate with an `E` after
  /// the serial (e.g. "LER OO 39E"), per the 2015 Electric Mobility Act.
  ///
  /// Open to all-electric cars and to plug-in hybrids with at least 40km of
  /// electric range; the suffix is what lets a warden identify a vehicle
  /// entitled to the parking and lane privileges the Act grants.
  static PlateSpec electricFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits, suffix: 'E', idKind: 'electric');

  /// A seasonal plate: the standard plate with its months of validity printed
  /// at the right end, the first above a rule and the last below it.
  ///
  /// The vehicle may be used only within that window — a convertible registered
  /// `03` over `10` is on the road from 1 March to 31 October and insured and
  /// taxed only for those months. A season may wrap the year (`11` over `03`
  /// for a winter vehicle), so the two months are in no particular order.
  ///
  /// The months are slots, not a label, because they are the one thing on a
  /// seasonal plate that varies. [GermanPlateValidator] checks they are real
  /// months; it deliberately does not require the first to precede the last.
  static PlateSpec seasonalFor({
    int districtLetters = 2,
    GermanIdentifierGroup group = GermanIdentifierGroup.d,
    int? digits,
  }) => _carLike(districtLetters: districtLetters, group: group, digits: digits, season: true, idKind: 'seasonal');

  /// A dealer's plate (`06`): red on white, an area code and five digits
  /// beginning `06`, and no identifier letters.
  ///
  /// Held by a garage or dealership rather than issued against a vehicle, and
  /// moved between vehicles for test drives and transfers. That is why it has
  /// no identifier letters and why its number is six characters where a car's
  /// is capped at eight — it is not a registration, and [GermanPlateValidator]
  /// does not judge it.
  static PlateSpec dealerFor({int districtLetters = 2}) =>
      _serialPlate(kind: 'dealer', districtLetters: districtLetters);

  /// A collector's plate (`07`): red on white, five digits beginning `07`.
  ///
  /// For a classic vehicle driven only to rallies, test drives and workshops,
  /// and — unlike an `H` plate — usable across several vehicles in one
  /// collection. It carries the registration seal and no inspection sticker:
  /// the vehicles it covers are not in regular service, so there is no
  /// *Hauptuntersuchung* to record.
  static PlateSpec collectorFor({int districtLetters = 2}) =>
      _serialPlate(kind: 'collector', districtLetters: districtLetters, inspectionSticker: false);

  /// The `06` and `07` numbers: an area code, the seal, and five red digits.
  ///
  /// Their own specs rather than [carFor] with an argument, because they break
  /// the two rules that define a car plate — a five-digit serial where the
  /// register holds four, and six to eight characters with the leading zero
  /// that a registration may never start with.
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

  /// The shape checks [carFor] and its variants share, in front of [_plate].
  ///
  /// [ink] null is the theme's black. [suffix] is the single fixed character
  /// printed hard against the serial — `H` or `E` — and is a [PlateLabel], not
  /// a slot: it never varies, so making it editable would invite a plate
  /// reading "…39Q". It still sits in the character flow and still lengthens
  /// the plate, because on a real plate it does both.
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
    // The suffix counts against the cap: an H or an E is part of the
    // Kennzeichen, not an ornament hung off the end of it. The season months
    // do not — they are a validity period printed on the plate, not part of
    // the registration, which is why a seasonal plate can carry eight
    // characters and four more digits besides.
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

  /// The one geometry every German plate in this package is laid out by: an
  /// area code, the round stickers, an identifier of letters and digits, and
  /// optionally a printed suffix or a stacked season block at the right end.
  ///
  /// Takes raw counts rather than a [GermanIdentifierGroup] because the formats
  /// that are *not* car plates — the 06 dealer and 07 collector numbers — carry
  /// no identifier letters and five digits, a shape no group describes. They
  /// are still the same plate with the same pitches, so they share this rather
  /// than forking it; what they do not share is [_carLike]'s rules, which is
  /// why the checks sit in front of this and not inside it.
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
    // Each run starts where the previous one ended, plus its gap. The stickers
    // are not a fixed-position pair in a fixed gap: on a real plate they sit
    // immediately after the *last* area-code letter, whichever letter that is,
    // and the identifier begins immediately after them.
    final districtRight = _districtLeft + (districtLetters - 1) * _letterPitch + _letterWidth;
    final decalLeft = districtRight + _decalGapBefore;
    final identifierLeft = decalLeft + _decalSize + _decalGapAfter;
    // A format with no identifier letters — the 06 and 07 numbers — has its
    // serial start where those letters would have: the max keeps the one-run
    // arithmetic from stepping backwards on a count of zero.
    final identifierRight = identifierLetters == 0
        ? identifierLeft - _serialGap
        : identifierLeft + (identifierLetters - 1) * _letterPitch + _letterWidth;
    final serialLeft = identifierRight + _serialGap;
    final serialRight = serialLeft + (serialDigits - 1) * _digitPitch + _digitWidth;
    // Flush against the last digit, with none of the inter-digit gap: on
    // "HL TL 15H" and "LER OO 39E" the suffix touches the serial.
    final charactersRight = suffix == null ? serialRight : serialRight + _letterWidth;
    // The season block is half-height and stacked, so it is short and wide
    // where the characters are tall and narrow — two digits' worth of width
    // buys four digits and a rule.
    final seasonLeft = charactersRight + _seasonGap;
    final seasonRight = seasonLeft + _seasonDigitPitch + _seasonDigitWidth;
    final contentRight = season ? seasonRight : charactersRight;

    final firstIdentifier = districtLetters;
    final firstSerial = firstIdentifier + identifierLetters;
    final firstSeason = firstSerial + serialDigits;

    return PlateSpec(
      // Ids are this library's equality and persistence key — see [_idFor].
      id: id,
      country: GermanyCountry.germany,
      inkOverride: ink,
      canvasWidth: contentRight + _rightMargin,
      canvasHeight: 110,
      panel: const PlatePanel(
        // Overlap the border on the three touching edges — see IranPlates.car.
        box: PlateBox(0, 0, 56.4, 110),
      ),
      textDirection: TextDirection.ltr,
      slots: [
        // Area code, e.g. "DA" or "CUX". Over the German alphabet, not the
        // plain Latin one: only the area code may carry an umlaut.
        ...plateRegister(
          alphabet: GermanAlphabets.districtLetters,
          count: districtLetters,
          left: _districtLeft,
          top: _top,
          width: _letterWidth,
          height: _height,
          pitch: _letterPitch,
        ),
        // Identifier letters, e.g. "X" or "DP". Latin only.
        ...plateRegister(
          alphabet: PlateAlphabet.latinUppercase,
          count: identifierLetters,
          left: identifierLeft,
          top: _top,
          width: _letterWidth,
          height: _height,
          pitch: _letterPitch,
        ),
        // The serial, e.g. "1953". Digits are narrower than letters.
        ...plateRegister(
          alphabet: PlateAlphabet.latinDigits,
          count: serialDigits,
          left: serialLeft,
          top: _top,
          width: _digitWidth,
          height: _height,
          pitch: _digitPitch,
        ),
        // The season: the first month of validity above, the last below. Two
        // registers rather than one four-digit one, because the rule between
        // them is what makes "03 over 10" read as March-to-October rather than
        // as the number 0310.
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
        // Stacked in the gap after the area code: the vehicle-inspection
        // sticker on top, the federal-state registration seal below. A plate
        // for a vehicle that is not registered to be driven — a collector's 07
        // number — carries the seal alone: there is no inspection to record.
        if (inspectionSticker)
          PlateDecal(
            image: const AssetImage('assets/de_inspection_sticker.png', package: 'germany_plate'),
            box: PlateBox(decalLeft, 14, _decalSize, _decalSize),
          ),
        PlateDecal(
          image: const AssetImage('assets/de_state_seal.png', package: 'germany_plate'),
          // Centred on the character line when it is the only sticker, rather
          // than sitting low with a gap above it where the other one was.
          box: PlateBox(decalLeft, inspectionSticker ? 54 : 36, _decalSize, _decalSize),
        ),
      ],
      labels: [
        if (suffix != null) PlateLabel(text: suffix, box: _printedBox(serialRight, _letterWidth), glyphHeight: _height),
      ],
      textGroups: [
        PlateTextGroup([for (var i = 0; i < districtLetters; i++) i], key: 'district'),
        PlateTextGroup([for (var i = 0; i < identifierLetters; i++) firstIdentifier + i], key: 'letters'),
        // The suffix rides on the serial group's rendering rather than getting
        // a group of its own: a [PlateTextGroup] indexes slots, and the suffix
        // is a label. [PlateTextGroup.prefix] is the only literal a group can
        // carry and it goes on the wrong end, so a caller reading the plate as
        // text appends the suffix itself — see [suffixOf].
        PlateTextGroup([for (var i = 0; i < serialDigits; i++) firstSerial + i], key: 'serial'),
        if (season) ...[
          PlateTextGroup([firstSeason, firstSeason + 1], key: 'seasonStart'),
          PlateTextGroup([firstSeason + 2, firstSeason + 3], key: 'seasonEnd'),
        ],
      ],
    );
  }

  /// The fixed character printed after [spec]'s serial — `'H'` for a historic
  /// plate, `'E'` for an electric one — or `''` for a plate with no suffix.
  ///
  /// A suffix is a [PlateLabel], so it is not in `spec.slots` and does not show
  /// up in the plain-text rendering [PlateSpec.renderGroup] builds. This is how
  /// a caller that wants the whole registration as a string gets the last
  /// character back.
  static String suffixOf(PlateSpec spec) {
    for (final MapEntry(key: kind, value: suffix) in _suffixKinds.entries) {
      if (spec.id.startsWith('de.car.$kind')) return suffix;
    }
    return '';
  }

  static const Map<String, String> _suffixKinds = {'historic': 'H', 'electric': 'E'};

  /// Whether [spec] carries the stacked season block.
  ///
  /// Asked of the spec's own groups rather than its id, because the groups are
  /// what a validator and a host actually read: a spec with a `seasonStart`
  /// group has months to judge and to display, whatever it is called.
  static bool isSeasonal(PlateSpec spec) => spec.textGroups.any((group) => group.key == 'seasonStart');

  /// Every shape the law issues, in a stable order — each area-code length
  /// against each group and serial length that fits in eight characters.
  ///
  /// What a gallery enumerates and what the spec test sweeps, so neither has to
  /// keep its own hand-written list of shapes in step with [carFor].
  static final List<PlateSpec> allCars = List<PlateSpec>.unmodifiable(<PlateSpec>[
    for (final shape in _shapes) carFor(districtLetters: shape.$1, group: shape.$2, digits: shape.$3),
  ]);

  /// The variants built on the standard car geometry: the green tax-exempt
  /// plate in every shape, and the `H` and `E` plates in every shape that still
  /// fits in eight characters once the suffix is counted.
  ///
  /// A sibling of [allCars] rather than part of it, so a caller that wants "the
  /// ordinary plate, in each shape it is issued" — a picker, a gallery's first
  /// page — still gets exactly that. [allSpecs] is the two together.
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

  /// The formats that are not car plates: the `06` dealer and `07` collector
  /// numbers, in each area-code length.
  ///
  /// A sibling list of its own because [GermanPlateValidator] does not apply to
  /// these — see [validatorFor]. Grouping them with the car plates would invite
  /// a caller to hand the whole list one validator.
  static final List<PlateSpec> allSerialPlates = List<PlateSpec>.unmodifiable(<PlateSpec>[
    for (var districtLetters = 1; districtLetters <= 3; districtLetters++) ...[
      dealerFor(districtLetters: districtLetters),
      collectorFor(districtLetters: districtLetters),
    ],
  ]);

  /// The formats that carry an expiry date on a coloured band: the `04`
  /// short-term number and the export number, in each area-code length.
  ///
  /// Their own list for the reason [allSerialPlates] is: neither is a
  /// registration, and neither is judged by [GermanPlateValidator].
  static final List<PlateSpec> allDatedPlates = List<PlateSpec>.unmodifiable(<PlateSpec>[
    for (var districtLetters = 1; districtLetters <= 3; districtLetters++) ...[
      shortTermFor(districtLetters: districtLetters),
      exportFor(districtLetters: districtLetters),
    ],
  ]);

  /// The validator that judges [spec].
  ///
  /// Not every German plate is a registration, and [GermanPlateValidator]'s
  /// rules describe only the ones that are: a serial of at most four digits
  /// that never starts with a zero, an identifier of one or two letters, eight
  /// characters in all. The `06` and `07` numbers break every one of those, and
  /// handing them that validator would paint a perfectly correct dealer plate
  /// red. So the choice of validator is made here, from the spec, rather than
  /// left to a caller who has no way of knowing which rules apply.
  ///
  /// The car variants — green, `H`, `E`, seasonal — are registrations and keep
  /// [GermanPlateValidator]; it reads the season block off the same spec when
  /// there is one.
  static PlateValidator validatorFor(PlateSpec spec) => switch (spec.id) {
    final id when id.startsWith('de.dealer') => const GermanSerialPlateValidator.dealer(),
    final id when id.startsWith('de.collector') => const GermanSerialPlateValidator.collector(),
    final id when id.startsWith('de.shortterm') => const GermanDatedPlateValidator.shortTerm(),
    final id when id.startsWith('de.export') => const GermanDatedPlateValidator.export(),
    final id when id.startsWith('de.bundeswehr') => const GermanBundeswehrValidator(),
    _ => const GermanPlateValidator(),
  };

  /// A short-term plate (`04`): black on white, an area code, one seal, five
  /// digits beginning `04`, and a yellow band on the right carrying the expiry
  /// date stacked DD/MM/YY.
  ///
  /// Valid for a maximum of four weeks and used for vehicle transfers, test
  /// drives, and temporary registration. The expiry date is editable — every
  /// deployment is different.
  static PlateSpec shortTermFor({int districtLetters = 2}) =>
      _rightBandPlate(kind: 'shortterm', districtLetters: districtLetters, band: _shortTermBand);

  /// An export plate (`Ausfuhrkennzeichen`): black on white, structured like a
  /// short-term but with a red band and carrying a different expiry date.
  ///
  /// For vehicles being exported or in transit to be exported. Issued for up to
  /// one year.
  ///
  /// The same plate as [shortTermFor] in every dimension; the band's fill is
  /// the whole difference, which is why both call [_rightBandPlate] with a
  /// colour rather than each describing a geometry of its own.
  static PlateSpec exportFor({int districtLetters = 2}) =>
      _rightBandPlate(kind: 'export', districtLetters: districtLetters, band: _exportBand);

  /// The `04` and export numbers: no euroband, an area code, the seal, five
  /// digits, and a full-height coloured band carrying the expiry date stacked
  /// DD over MM over YY.
  ///
  /// The date is slots rather than a label, for the same reason the season
  /// months are: it is the one thing on these plates that varies, and a plate
  /// whose whole point is that it expires has no business printing a fixed day.
  ///
  /// No inspection sticker. A vehicle on an `04` or an export number has no
  /// current *Hauptuntersuchung* to record — the band is the validity period,
  /// and it is the only one these plates carry.
  static PlateSpec _rightBandPlate({required String kind, required int districtLetters, required Color band}) {
    if (districtLetters < 1 || districtLetters > 3) {
      throw ArgumentError.value(districtLetters, 'districtLetters', 'An area code carries one, two or three letters');
    }

    const serialDigits = 5;
    final districtRight = _bareLeft + (districtLetters - 1) * _letterPitch + _letterWidth;
    final decalLeft = districtRight + _decalGapBefore;
    final serialLeft = decalLeft + _decalSize + _decalGapAfter;
    final serialRight = serialLeft + (serialDigits - 1) * _digitPitch + _digitWidth;
    // The band runs to the right-hand edge: there is no right margin on these
    // plates, because the band *is* the end of the plate.
    final bandLeft = serialRight + _bandGap;
    final canvasWidth = bandLeft + _bandWidth;
    // The date register, centred in the band: two cells at a pitch, so the run
    // is one pitch plus one cell wide.
    final dateLeft = bandLeft + (_bandWidth - (_bandDigitPitch + _bandDigitWidth)) / 2;

    final firstDate = districtLetters + serialDigits;

    return PlateSpec(
      id: 'de.$kind${districtLetters == 2 ? '' : '.$districtLetters'}',
      country: GermanyCountry.germany,
      canvasWidth: canvasWidth,
      canvasHeight: 110,
      // No euroband. The panel still declares a (zero-width) geometry because
      // every spec has one; [PlateSpec.noPanel] is what stops it being painted.
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
        // The expiry date: day, month and year, one two-digit register per row
        // of the band. Three registers rather than one six-digit one, because
        // the rows are what make "09 03 04" read as a date.
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
        // The seal alone, centred on the character line — as on the 07
        // collector number, and for the same reason.
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

  /// A Bundeswehr plate: the German flag printed where the euroband would be,
  /// a `Y`, a printed hyphen, and six digits in two triples.
  ///
  /// The armed forces register their own vehicles, so the plate carries the
  /// Bundeswehr's registration seal and no inspection sticker — the
  /// *Hauptuntersuchung* a civilian plate records is not what a military
  /// vehicle is inspected under.
  ///
  /// The hyphen is a [PlateLabel], not a slot, for the reason the `H` and `E`
  /// suffixes are: it never varies. The `Y` *is* a slot — it is the area code's
  /// position, and the area code is a register on every German format in this
  /// package — and [GermanBundeswehrValidator] is what says it must read `Y`.
  static PlateSpec bundeswehrFor({int districtLetters = 1}) {
    if (districtLetters < 1 || districtLetters > 3) {
      throw ArgumentError.value(districtLetters, 'districtLetters', 'An area code carries one, two or three letters');
    }

    final districtLeft = _flagPanelWidth + _flagGapAfter;
    final districtRight = districtLeft + (districtLetters - 1) * _letterPitch + _letterWidth;
    final hyphenRight = districtRight + _hyphenWidth;
    final serialLeft = hyphenRight + _hyphenGapAfter;
    // Six digits in two triples. One evenly-pitched run of six would be a
    // different plate: "Y-751957" is printed as "751" and "957".
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
        // Sized so the flag exactly fills the padding box: the block carries no
        // caption, so the default 10% inset would leave it small and top-left.
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
        // The registration seal, tucked under the hyphen, where the Bundeswehr
        // prints its own Zulassungssiegel.
        PlateDecal(
          image: const AssetImage('assets/de_state_seal.png', package: 'germany_plate'),
          box: PlateBox(districtRight, 60, _decalSize, _decalSize),
        ),
      ],
      labels: [PlateLabel(text: '-', box: _printedBox(districtRight, _hyphenWidth), glyphHeight: _height)],
      textGroups: [
        PlateTextGroup([for (var i = 0; i < districtLetters; i++) i], key: 'district'),
        // Two keyed triples rather than one six-digit register: they sit either
        // side of a gap, so one group would be an unevenly-pitched register and
        // `debugValidateSpec` says so. [GermanBundeswehrValidator] reads both.
        PlateTextGroup([firstSerial, firstSerial + 1, firstSerial + 2], key: 'serial'),
        PlateTextGroup([firstSerial + 3, firstSerial + 4, firstSerial + 5], key: 'serialTail'),
      ],
    );
  }

  /// Every spec this package declares, which is what the spec test sweeps
  /// through `debugValidateSpec`. Adding a list above adds it here too.
  static final List<PlateSpec> allSpecs = List<PlateSpec>.unmodifiable(<PlateSpec>[
    ...allCars,
    ...allCarVariants,
    ...allSerialPlates,
    ...allDatedPlates,
    bundeswehrFor(),
  ]);

  /// Each (area-code length, group, serial length) the law issues, in a stable
  /// order. Shared by [allCars] and [allCarVariants] so the two cannot drift.
  ///
  /// `final`, not `const`: a `for` element is not a constant expression.
  static final List<(int, GermanIdentifierGroup, int)> _shapes = [
    for (var districtLetters = 1; districtLetters <= 3; districtLetters++)
      for (final group in GermanIdentifierGroup.values)
        for (var digits = group.minDigits; digits <= group.maxDigits; digits++)
          if (districtLetters + group.letters + digits <= 8) (districtLetters, group, digits),
  ];

  /// Ids read `de.car`, `de.car.<district>-<letters>-<digits>` for a shape
  /// other than the common one, and `de.car.<kind>…` for a variant printed on
  /// that shape. The common shape keeps the bare `de.car` it has always had, so
  /// a persisted id still resolves.
  static String _idFor(int districtLetters, GermanIdentifierGroup group, int digits, String? kind) {
    final shape = districtLetters == 2 && group == GermanIdentifierGroup.d && digits == 4
        ? ''
        : '.$districtLetters-${group.letters}-$digits';
    return kind == null ? 'de.car$shape' : 'de.car.$kind$shape';
  }
}
