import 'package:assignment2/currency_selector_page.dart';
import 'package:flutter/material.dart';
import 'rates_page.dart';
import '../services/api_service.dart';
import '../models/currency.dart';
import '../services/location_service.dart';

const Map<String, double> exchangeRates = {
  'EUR': 1.0,
  'USD': 1.1,
  'SEK': 11.0,
  'GBP': 0.85,
  'CNY': 7.5,
  'JPY': 155.0,
  'KRW': 1450.0,
};

const Map<String, String> currencyFlags = {
  'EUR': 'lib/icons/world.png',
  'USD': 'lib/icons/usa.png',
  'GBP': 'lib/icons/united-kingdom.png',
  'SEK': 'lib/icons/sweden.png',
  'CNY': 'lib/icons/china.png',
  'JPY': 'lib/icons/japan.png',
  'KRW': 'lib/icons/south-korea.png',
};

final List<String> currencies = exchangeRates.keys
    .toList(); // copying the currencies names into a list  ( EUR, USD, SEK ....)

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // constructor

  @override
  _HomePageState createState() => _HomePageState(); // mutable state
}

class _HomePageState extends State<HomePage> {
  String fromCurrency = currencies.first;
  String toCurrency = currencies[1];
  double amount = 1.0;
  double convertedAmount = 1.0;

  double get unitRate {
    final rateFrom = exchangeRates[fromCurrency]!;
    final rateTo = exchangeRates[toCurrency]!;
    if (fromCurrency == toCurrency) return 1.0;
    return (1 / rateFrom) * rateTo;
  }

  void updateConversion() {
    double rateFrom = exchangeRates[fromCurrency]!;
    double rateTo = exchangeRates[toCurrency]!;

    setState(() {
      if (fromCurrency == toCurrency) {
        convertedAmount = amount;
      } else {
        convertedAmount = (amount / rateFrom) * rateTo;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121217),
      // slightly lighter dark
      appBar: AppBar(
        backgroundColor: const Color(0xFF121217),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 120,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Currency Converter',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 12,
                    color: Color(0xAA64B5F6),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Student-developed app that instantly converts currencies',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9FBEDC),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // FIRST ROW
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141416),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2E4A66),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF64B5F6,
                                  ).withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CurrencySelectorPage(
                                      selectedCurrency: fromCurrency,
                                    ),
                                  ),
                                );

                                if (result != null) {
                                  setState(() {
                                    fromCurrency = result;
                                    updateConversion();
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    currencyFlags[fromCurrency]!,
                                    width: 26,
                                    height: 26,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    fromCurrency,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.blueAccent,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // AMOUNT INPUT
                        Expanded(
                          flex: 2,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Amount",
                              labelStyle: const TextStyle(
                                color: Color(0xFF8FCBF9),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF151515),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2E4A66),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF64B5F6),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              amount = double.tryParse(val) ?? 0;
                              updateConversion();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // SWAP BUTTON
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D3B57),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF64B5F6).withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.swap_vert,
                          size: 34,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            final temp = fromCurrency;
                            fromCurrency = toCurrency;
                            toCurrency = temp;
                          });
                          updateConversion();
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // SECOND ROW
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141416),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2E4A66),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF64B5F6,
                                  ).withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CurrencySelectorPage(
                                      selectedCurrency: toCurrency,
                                    ),
                                  ),
                                );

                                if (result != null) {
                                  setState(() {
                                    toCurrency = result;
                                    updateConversion();
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    currencyFlags[toCurrency]!,
                                    width: 26,
                                    height: 26,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    toCurrency,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.blueAccent,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // CONVERTED RESULT BOX
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141416),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2E4A66),
                              ),
                            ),
                            child: Text(
                              convertedAmount.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              // NAVIGATION BUTTON
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RatesPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5A86),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'View Exchange Rates',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          decoration: BoxDecoration(
            color: const Color(0xFF141416),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E4A66)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Indicative Exchange Rate',
                style: TextStyle(color: Color(0xFF9FBEDC), fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                '1 $fromCurrency - ${unitRate.toStringAsFixed(2)} $toCurrency',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFBEE7FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
