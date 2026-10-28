/// The five issued identifier shapes (FZV Appendix 1). Group e cannot pair with
/// a 3-letter area code (exceeds 8-character maximum).
enum GermanIdentifierGroup {
  a(letters: 1, minDigits: 1, maxDigits: 3),
  b(letters: 2, minDigits: 1, maxDigits: 2),
  c(letters: 2, minDigits: 3, maxDigits: 3),
  d(letters: 1, minDigits: 4, maxDigits: 4),
  e(letters: 2, minDigits: 4, maxDigits: 4);

  const GermanIdentifierGroup({
    required this.letters,
    required this.minDigits,
    required this.maxDigits,
  });

  /// How many letters the identifier's letter block carries.
  final int letters;

  /// The inclusive bounds on the serial's digit count.
  final int minDigits, maxDigits;

  /// True when [digits] is in the valid range for this group.
  bool admitsDigits(int digits) => digits >= minDigits && digits <= maxDigits;

  /// Group for a given letter/digit count, or null if not issued.
  static GermanIdentifierGroup? of({
    required int letters,
    required int digits,
  }) {
    for (final group in values) {
      if (group.letters == letters && group.admitsDigits(digits)) return group;
    }
    return null;
  }
}
