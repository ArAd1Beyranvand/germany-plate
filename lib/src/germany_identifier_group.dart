/// The five shapes a German `Erkennungsnummer` is issued in.
///
/// The identifier is not free-form within "one or two letters and one to four
/// digits": FZV Appendix 1 enumerates exactly five groups, and a combination
/// outside them is not issued by any authority. So this is a closed set the law
/// owns, which is what a Dart `enum` is for — unlike plate kinds or countries,
/// no consumer of this package can add a sixth group.
///
/// | Group | Letters | Digits | Range           |
/// |-------|---------|--------|-----------------|
/// | a     | 1       | 1-3    | A1 - Z999       |
/// | b     | 2       | 1-2    | AA1 - ZZ99      |
/// | c     | 2       | 3      | AA100 - ZZ999   |
/// | d     | 1       | 4      | A1000 - Z9999   |
/// | e     | 2       | 4      | AA1000 - ZZ9999 |
///
/// Not every authority issues every group, and group [e] cannot be combined
/// with a three-letter area code — 3 + 2 + 4 is nine characters, and a plate
/// may carry at most eight. That exclusion therefore needs no separate field:
/// it falls out of the length cap, which is checked where the cap is.
enum GermanIdentifierGroup {
  a(letters: 1, minDigits: 1, maxDigits: 3),
  b(letters: 2, minDigits: 1, maxDigits: 2),
  c(letters: 2, minDigits: 3, maxDigits: 3),
  d(letters: 1, minDigits: 4, maxDigits: 4),
  e(letters: 2, minDigits: 4, maxDigits: 4);

  const GermanIdentifierGroup({required this.letters, required this.minDigits, required this.maxDigits});

  /// How many letters the identifier's letter block carries.
  final int letters;

  /// The inclusive bounds on the serial's digit count.
  final int minDigits, maxDigits;

  /// True when [digits] is a serial length this group is issued with.
  bool admitsDigits(int digits) => digits >= minDigits && digits <= maxDigits;

  /// The group a given letter/digit count falls in, or null when no group is
  /// issued in that shape (e.g. two letters and no digits).
  ///
  /// The lookup a validator needs: it is handed a plate's characters and must
  /// decide whether their shape is one the law issues, without the caller
  /// having named a group.
  static GermanIdentifierGroup? of({required int letters, required int digits}) {
    for (final group in values) {
      if (group.letters == letters && group.admitsDigits(digits)) return group;
    }
    return null;
  }
}
