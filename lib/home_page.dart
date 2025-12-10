import 'package:flutter/material.dart';
import 'currency_selector_page.dart';
import 'rates_page.dart';
import '../services/api_service.dart';
import '../models/currency.dart';
import '../services/location_service.dart';

const Map<String, String> currencyFlags = {
  'EUR': 'lib/icons/world.png',
  'USD': 'lib/icons/usa.png',
  'GBP': 'lib/icons/united-kingdom.png',
  'SEK': 'lib/icons/sweden.png',
  'CNY': 'lib/icons/china.png',
  'JPY': 'lib/icons/japan.png',
  'KRW': 'lib/icons/south-korea.png',
};

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

  double get unitRate {
    if (currencyData == null || fromCurrency == null || toCurrency == null)
      return 0.0;
    final rateFrom = currencyData!.rates[fromCurrency] ?? 1.0;
    final rateTo = currencyData!.rates[toCurrency] ?? 1.0;
    if (fromCurrency == toCurrency) return 1.0;
    return (1 / rateFrom) * rateTo;
  }

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    // Get user's local currency
    fromCurrency = await LocationService.getCurrencyFromLocation();

    // Fetch live rates
    currencyData = await ApiService.fetchCurrency();

    updateConversion();
    setState(() {});
  }

  void updateConversion() {
    if (currencyData == null || fromCurrency == null || toCurrency == null)
      return;
    final rateFrom = currencyData!.rates[fromCurrency] ?? 1.0;
    final rateTo = currencyData!.rates[toCurrency] ?? 1.0;

    setState(() {
      convertedAmount = (fromCurrency == toCurrency)
          ? amount
          : (amount / rateFrom) * rateTo;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currencyData == null || fromCurrency == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121217),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121217),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121217),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 120,
        title: Column(
          children: const [
            Text(
              'Currency Converter',
              style: TextStyle(
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
              style: TextStyle(fontSize: 14, color: Color(0xFF9FBEDC)),
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
                    // FROM CURRENCY + AMOUNT
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildCurrencyButton(
                            selected: fromCurrency!,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CurrencySelectorPage(
                                    selectedCurrency: fromCurrency!,
                                    currencyData: currencyData!,
                                  ),
                                ),
                              );
                              if (result != null) {
                                fromCurrency = result;
                                updateConversion();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: _buildAmountField()),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // SWAP BUTTON
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D3B57),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.swap_vert,
                          color: Colors.white,
                          size: 34,
                        ),
                        onPressed: () {
                          final temp = fromCurrency;
                          fromCurrency = toCurrency;
                          toCurrency = temp;
                          updateConversion();
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // TO CURRENCY + RESULT
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildCurrencyButton(
                            selected: toCurrency!,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CurrencySelectorPage(
                                    selectedCurrency: toCurrency!,
                                    currencyData: currencyData!,
                                  ),
                                ),
                              );
                              if (result != null) {
                                toCurrency = result;
                                updateConversion();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: _buildResultBox()),
                      ],
                    ),
                  ],
                ),
              ),

              // VIEW RATES BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RatesPage(currencyData: currencyData!),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5A86),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'View Exchange Rates',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // FOOTER: 1 FROM = X TO
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 60),
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
                '1 $fromCurrency = ${unitRate.toStringAsFixed(2)} $toCurrency',
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

  Widget _buildCurrencyButton({
    required String selected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E4A66)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Image.asset(currencyFlags[selected]!, width: 26, height: 26),
            const SizedBox(width: 10),
            Text(
              selected,
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
    );
  }

  Widget _buildAmountField() {
    return TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Amount",
        labelStyle: const TextStyle(color: Color(0xFF8FCBF9)),
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
      onChanged: (val) {
        amount = double.tryParse(val) ?? 0;
        updateConversion();
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
