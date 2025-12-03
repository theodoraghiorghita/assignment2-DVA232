import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/currency.dart';

class ApiService {
  static const String baseUrl = 'http://data.fixer.io/api/';
  static const String apiKey = 'c898652d82183843dfc9b62a1d7a9356';

  static Future<Currency?> fetchCurrency(String fromCurrency) async {
    try {
      final url = Uri.parse('$baseUrl/latest?access_key=$apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return Currency.fromJson(json.decode(response.body));
      } else {
        print('Failed to load currency data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching currency data: $e');
      return null;
    }
  }
}
