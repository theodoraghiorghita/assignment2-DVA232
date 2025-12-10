import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Get current device position
  static Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Convert coordinates to country code (ISO 3166-1 alpha-2)
  static Future<String?> getCountryCode(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }
    } catch (e) {
      print("Error getting country code: $e");
    }
    return null;
  }

  /// Map country code to currency code
  static String mapCountryToCurrency(String countryCode) {
    switch (countryCode) {
      case "US":
        return "USD";
      case "GB":
        return "GBP";
      case "JP":
        return "JPY";
      case "KR":
        return "KRW";
      case "SE":
        return "SEK";
      case "CN":
        return "CNY";
      case "FR":
      case "DE":
      case "IT":
      case "ES":
      case "EU":
        return "EUR";
      default:
        return "EUR"; // fallback
    }
  }

  /// Main function to get currency from user location
  static Future<String> getCurrencyFromLocation() async {
    final position = await determinePosition();
    if (position == null) return "EUR"; // fallback

    final countryCode = await getCountryCode(position);
    if (countryCode == null) return "EUR"; // fallback

    return mapCountryToCurrency(countryCode);
  }
}
