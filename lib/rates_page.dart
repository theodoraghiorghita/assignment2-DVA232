// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import '../models/currency.dart';
import 'utils/currency_utils.dart';

class RatesPage extends StatefulWidget {
  final Currency currencyData;
  final String fromCurrency; // <-- add this

  const RatesPage({
    super.key,
    required this.currencyData,
    required this.fromCurrency, // <-- add this
  });

  @override
  _RatesPageState createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  late String exchangecurrency;
  List<String> filteredCurrencies = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use the provided fromCurrency when available, otherwise fall back
    // to the API base or the first available currency to avoid crashes.
    if (widget.currencyData.rates.containsKey(widget.fromCurrency)) {
      exchangecurrency = widget.fromCurrency;
    } else if (widget.currencyData.rates.containsKey(
      widget.currencyData.base,
    )) {
      exchangecurrency = widget.currencyData.base;
    } else {
      exchangecurrency = widget.currencyData.rates.keys.first;
    }

    // Create a deterministic, sorted list of currencies for display.
    filteredCurrencies = widget.currencyData.rates.keys.toList()..sort();
  }

  void filterCurrencies(String query) {
    final allCurrencies = widget.currencyData.rates.keys.toList();
    setState(() {
      filteredCurrencies = allCurrencies.where((currency) {
        final codeMatch = currency.toLowerCase().contains(query.toLowerCase());
        final countryMatch = currencyCodeToCountryName(
          currency,
        ).toLowerCase().contains(query.toLowerCase());
        return codeMatch || countryMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exchangeRates = widget.currencyData.rates;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFBEE7FF)),
        title: const Text(
          'Exchange Rates',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search currency or country",
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: const Color(0xFF151515),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue.shade800),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue.shade800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                ),
              ),
              onChanged: filterCurrencies,
            ),

            const SizedBox(height: 16),

            // Currency Rates List
            Expanded(
              child: ListView.builder(
                itemCount: filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = filteredCurrencies[index];
                  final baseRate = exchangeRates[exchangecurrency] ?? 1.0;
                  final targetRate = exchangeRates[currency] ?? 1.0;
                  final converted = (baseRate == 0)
                      ? 0.0
                      : (targetRate / baseRate);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade800),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade900.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        flagForCurrency(currency, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '1 $exchangecurrency = ${converted.toStringAsFixed(2)} $currency',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
