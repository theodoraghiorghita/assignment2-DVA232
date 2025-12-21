import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

class ApiService {
  static const String apiKey = 'c898652d82183843dfc9b62a1d7a9356';
  static const String baseUrl = 'https://data.fixer.io/api/latest';

  static Future<Currency> fetchCurrency() async {
    final url = Uri.parse('$baseUrl?access_key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Currency.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch exchange rates');
    }
  }
}
