import 'package:flutter/material.dart';
import '../data/country_currency.dart' as cc;

String currencyCodeToCountryName(String currency) {
  return cc.currencyToCountryName[currency] ?? "Unknown";
}

String currencyToCountryCode(String currency) {
  return cc.currencyToCountryCode[currency] ?? "unknown";
}

Widget flagForCurrency(String currency, {double size = 32}) {
  final code = currencyToCountryCode(currency).toLowerCase();

  // Don't show a flag for currencies without a real country
  if (code == "unknown") {
    return SizedBox(width: size, height: size);
  }

  return Image.asset(
    'icons/flags/png/$code.png',
    package: 'country_icons',
    width: size,
    height: size,
    errorBuilder: (context, error, stack) =>
        SizedBox(width: size, height: size),
  );
}
