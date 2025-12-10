class Currency {
  final bool success;
  final String base;
  final Map<String, double> rates;

  Currency({required this.success, required this.base, required this.rates});

  factory Currency.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>;

    final convertedRates = rawRates.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return Currency(
      success: json['success'] ?? false,
      base: json['base'] ?? 'EUR',
      rates: convertedRates,
    );
  }
}
