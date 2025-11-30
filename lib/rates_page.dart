import 'package:flutter/material.dart';
import 'home_page.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  _RatesPageState createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  String exchangecurrency = currencies[1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // matte black
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
            // Currency Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade800),
              ),
              child: DropdownButtonFormField<String>(
                value: exchangecurrency,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Select Currency",
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: InputBorder.none,
                ),
                iconEnabledColor: Colors.blueAccent,
                isExpanded: true,
                items: currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Row(
                      children: [
                        Image.asset(
                          currencyFlags[currency]!,
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          currency,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    exchangecurrency = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Rates list
            Expanded(
              child: ListView.builder(
                itemCount: exchangeRates.length,
                itemBuilder: (context, index) {
                  String currency = exchangeRates.keys.elementAt(index);

                  double baseRate = exchangeRates[exchangecurrency]!;
                  double targetRate = exchangeRates[currency]!;
                  double converted = targetRate / baseRate;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade800),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade900.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(currencyFlags[currency]!, width: 32),
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
