// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import '../models/currency.dart';
import 'utils/currency_utils.dart';

class CurrencySelectorPage extends StatefulWidget {
  final String selectedCurrency;
  final Currency currencyData;

  const CurrencySelectorPage({
    super.key,
    required this.selectedCurrency,
    required this.currencyData,
  });

  @override
  _CurrencySelectorPageState createState() => _CurrencySelectorPageState();
}

class _CurrencySelectorPageState extends State<CurrencySelectorPage> {
  late String selectedCurrency;
  late List<String> allCurrencies;
  List<String> filteredCurrencies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.selectedCurrency;
    allCurrencies = widget.currencyData.rates.keys.toList()..sort();
    filteredCurrencies = List.from(allCurrencies);

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredCurrencies = allCurrencies.where((currency) {
        final countryName = currencyCodeToCountryName(currency).toLowerCase();
        return currency.toLowerCase().contains(query) ||
            countryName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFBEE7FF)),
        centerTitle: true,
        title: const Text(
          'Select Currency',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, selectedCurrency),
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Color(0xFF3B6EFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController, // <-- Controller added
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search currency or country",
                hintStyle: const TextStyle(color: Colors.white54),
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
            ),
          ),
          // List of filtered currencies
          Expanded(
            child: ListView.builder(
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = filteredCurrencies[index];
                final isSelected = currency == selectedCurrency;

                return GestureDetector(
                  onTap: () => setState(() => selectedCurrency = currency),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade900.withValues(alpha: 0.25)
                          : const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$currency (${currencyCodeToCountryName(currency)})',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, color: Color(0xFF3B6EFF)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
