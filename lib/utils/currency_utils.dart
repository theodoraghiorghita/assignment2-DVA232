import '../data/country_currency.dart' as cc;

String currencyCodeToCountryName(String currency) {
  return cc.currencyToCountryName[currency] ?? "Unknown";
}

String currencyToCountryCode(String currency) {
  return cc.currencyToCountryCode[currency] ?? "unknown";
}
