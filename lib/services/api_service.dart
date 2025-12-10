import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

class ApiService {
  static const String apiUrl = "https://api.exchangerate.host/latest";

  /// Fetch live rates and convert to Currency model
  static Future<Currency> fetchCurrency() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Currency.fromJson(jsonData);
    } else {
      throw Exception("Failed to fetch currency data");
    }
  }
}
