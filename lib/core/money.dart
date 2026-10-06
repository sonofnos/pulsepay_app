// Matches the backend: every balance is minor units (100 per major unit).
class Money {
  static String format(int minorUnits, String currency) {
    final major = minorUnits / 100;
    return '${_symbol(currency)}${major.toStringAsFixed(2)}';
  }

  static String _symbol(String currency) {
    switch (currency) {
      case 'NGN':
        return '₦';
      case 'BTC':
        return '₿';
      case 'USDT':
        return '\$';
      default:
        return '$currency ';
    }
  }

  static int? parseToMinorUnits(String input) {
    final value = double.tryParse(input.trim());
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }
}
