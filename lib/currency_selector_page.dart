import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../home_page.dart'; // for currencyFlags map

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

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    // Sorted currencies for consistent UX
    final List<String> currencies = widget.currencyData.rates.keys.toList()
      ..sort();

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
            onPressed: () {
              Navigator.pop(context, selectedCurrency);
            },
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

      // --------------------------------------------------------------
      // LIST OF CURRENCIES
      // --------------------------------------------------------------
      body: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          String currency = currencies[index];
          bool isSelected = currency == selectedCurrency;

          return Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade900.withOpacity(0.25) : null,
            ),
            child: ListTile(
              onTap: () => setState(() => selectedCurrency = currency),

              leading: Image.asset(
                currencyFlags[currency] ?? currencyFlags["EUR"]!,
                width: 32,
                height: 32,
              ),

              title: Text(
                currency,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),

              trailing: isSelected
                  ? const Icon(Icons.check, color: Color(0xFF3B6EFF))
                  : null,
            ),
          );
        },
      ),
    );
  }
}
