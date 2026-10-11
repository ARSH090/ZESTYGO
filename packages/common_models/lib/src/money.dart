/// Money in integer paise. All prices come from the server; the UI only displays them.
final class Money {
  const Money(this.paise);

  final int paise;

  Money operator +(Money other) => Money(paise + other.paise);
  Money operator -(Money other) => Money(paise - other.paise);

  /// Formats as rupees with two decimals, for example ₹512.90.
  String format() {
    final negative = paise < 0;
    final absolute = paise.abs();
    final rupees = absolute ~/ 100;
    final remainder = (absolute % 100).toString().padLeft(2, '0');
    return '${negative ? '-' : ''}₹$rupees.$remainder';
  }

  @override
  bool operator ==(Object other) => other is Money && other.paise == paise;

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() => 'Money($paise paise)';
}
