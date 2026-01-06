// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'currency_selector_page.dart';
import 'rates_page.dart';
import '../services/api_service.dart';
import '../models/currency.dart';
import '../services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Currency? currencyData;
  String? fromCurrency;
  String? toCurrency = 'USD';
  double amount = 1.0;
  double convertedAmount = 1.0;

  bool autoCurrencyEnabled = true; // listens to location changes

  double get unitRate {
    // exchange rate computation
    if (currencyData == null || fromCurrency == null || toCurrency == null) {
      return 0.0;
    }
    final rateFrom = currencyData!.rates[fromCurrency] ?? 1.0;
    final rateTo = currencyData!.rates[toCurrency] ?? 1.0;
    return (fromCurrency == toCurrency) ? 1.0 : (1 / rateFrom) * rateTo;
  }

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      try {
        currencyData = await ApiService.fetchCurrency().timeout(
          const Duration(seconds: 6),
        );
      } catch (_) {
        currencyData = Currency(
          success: true,
          base: "EUR",
          rates: {
            "EUR": 1.0,
            "USD": 1.1,
            "GBP": 0.85,
            "JPY": 160.0,
            "SEK": 11.0,
            "RON": 4.95,
          },
        );
      }

      fromCurrency = await LocationService.getCurrencyFromLocation(
        currencyData!,
      ).timeout(const Duration(seconds: 4), onTimeout: () => "EUR");

      if (!currencyData!.rates.containsKey(fromCurrency)) fromCurrency = "EUR";
      if (!currencyData!.rates.containsKey(toCurrency)) toCurrency = "USD";

      LocationService.startCurrencyListener(
        currencyData: currencyData!,
        onCurrencyChanged: (currency) {
          if (!autoCurrencyEnabled) return;
          if (currencyData == null) return;
          if (currency == fromCurrency) return;

          setState(() => fromCurrency = currency);
          _updateConversion();
        },
      );

      _updateConversion();
    } catch (_) {
      currencyData = Currency(
        success: true,
        base: "EUR",
        rates: {"EUR": 1.0, "USD": 1.1},
      );
      fromCurrency ??= "EUR";
      toCurrency ??= "USD";
      _updateConversion();
    } finally {
      setState(() {});
    }
  }

  void _updateConversion() {
    if (currencyData == null || fromCurrency == null || toCurrency == null) {
      return;
    }

    final rateFrom = currencyData!.rates[fromCurrency] ?? 1.0;
    final rateTo = currencyData!.rates[toCurrency] ?? 1.0;

    setState(() {
      convertedAmount = (fromCurrency == toCurrency)
          ? amount
          : (amount / rateFrom) * rateTo;
    });
  }

  @override
  void dispose() {
    if (!autoCurrencyEnabled) LocationService.stopCurrencyListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currencyData == null || fromCurrency == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121217),
        body: Center(child: CircularProgressIndicator()),
      );
    } // loading state

    return Scaffold(
      backgroundColor: const Color(0xFF121217),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121217),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 120,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
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
            SizedBox(height: 8),
            Text(
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
                    // FROM currency + amount
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildCurrencyButton(
                            selected: fromCurrency!,
                            onTap: () async {
                              final picked = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CurrencySelectorPage(
                                    selectedCurrency: fromCurrency!,
                                    currencyData: currencyData!,
                                  ),
                                ),
                              );
                              if (picked != null) {
                                setState(() => fromCurrency = picked);
                                _updateConversion();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: _buildAmountField()),
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
                            color: const Color(
                              0xFF64B5F6,
                            ).withValues(alpha: 0.18),
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
                          _updateConversion();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // TO currency + result
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildCurrencyButton(
                            selected: toCurrency!,
                            onTap: () async {
                              final picked = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CurrencySelectorPage(
                                    selectedCurrency: toCurrency!,
                                    currencyData: currencyData!,
                                  ),
                                ),
                              );
                              if (picked != null) {
                                setState(() => toCurrency = picked);
                                _updateConversion();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: _buildResultBox()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RatesPage(
                              currencyData: currencyData!,
                              fromCurrency:
                                  fromCurrency!, // pass selected currency
                            ),
                          ),
                        );
                      },
                      child: const Text('View Exchange Rates'),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141416),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E4A66)),
                ),
                child: Text(
                  '1 $fromCurrency = ${unitRate.toStringAsFixed(2)} $toCurrency',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  Widget _buildCurrencyButton({
    required String selected,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E4A66)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64B5F6).withValues(alpha: 0.18),
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
        onPressed: onTap,
        child: Row(
          children: [
            const SizedBox(width: 10),
            Text(
              selected,
              style: const TextStyle(
                color: Colors.white,
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
    );
  }

  Widget _buildAmountField() {
    return TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Amount',
        filled: true,
        fillColor: const Color(0xFF151515),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E4A66)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
        ),
      ),
      onChanged: (value) {
        amount = double.tryParse(value) ?? 0;
        _updateConversion();
      },
    );
  }

  Widget _buildResultBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E4A66)),
      ),
      child: Text(
        convertedAmount.toStringAsFixed(2),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
