import 'package:flutter/material.dart';
import 'package:assignment2/home_page.dart';

class CurrencySelectorPage extends StatefulWidget {
  final String selectedCurrency;

  const CurrencySelectorPage({super.key, required this.selectedCurrency});

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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // matte luxury black
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
              Navigator.pop(
                context,
                selectedCurrency,
              ); // return chosen currency
            },
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Color(0xFF3B6EFF), // royal blue
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          String currency = currencies[index];
          bool isSelected = currency == selectedCurrency;

          return ListTile(
            onTap: () {
              setState(() {
                selectedCurrency = currency;
              });
            },
            leading: Image.asset(
              currencyFlags[currency]!,
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
                ? const Icon(
                    Icons.check,
                    color: Color(0xFF3B6EFF), // royal blue
                  )
                : null,
            tileColor: isSelected
                ? Colors.blue.shade900.withOpacity(0.3)
                : Colors.transparent,
          );
        },
      ),
    );
  }
}
