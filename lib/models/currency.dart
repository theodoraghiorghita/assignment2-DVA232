class Currency {
  final bool success;
  final String fromCurrency;
  final Map<String, double> rates;

  Currency({
    required this.success,
    required this.fromCurrency,
    required this.rates,
  });
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      success: json['success'],
      fromCurrency: json['base'],
      rates: Map<String, double>.from(json['rates']),
    );
  }
}
