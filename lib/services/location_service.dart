import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import '../models/currency.dart';
import '../data/country_currency.dart';

class LocationService {
  static StreamSubscription<Position>? _positionSubscription;

  static Future<Position?> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      final pos =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 3),
            onTimeout: () =>
                throw TimeoutException('Location request timed out'),
          );

      return pos;
    } catch (_) {
      return null;
    }
  }

  // Get country code from position
  static Future<String?> getCountryCode(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 2), onTimeout: () => <Placemark>[]);

      if (placemarks.isNotEmpty) return placemarks.first.isoCountryCode;
    } catch (_) {}
    return null;
  }

  static String mapCountryToCurrency(
    String countryCode,
    Currency currencyData,
  ) {
    final currency = countryToCurrency[countryCode];
    if (currency != null && currencyData.rates.containsKey(currency)) {
      return currency;
    }
    return "EUR";
  }

  // Get currency code from location

  static Future<String> getCurrencyFromLocation(Currency currencyData) async {
    final position = await determinePosition();
    if (position == null) return "EUR";

    final countryCode = await getCountryCode(position);
    if (countryCode == null) return "EUR";

    return mapCountryToCurrency(countryCode, currencyData);
  }

  static void startCurrencyListener({
    required Currency currencyData,
    required void Function(String currency) onCurrencyChanged,
  }) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    String? lastCountryCode;

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 50,
          ),
        ).listen((position) async {
          final countryCode = await getCountryCode(position);

          if (countryCode == null) return;

          if (countryCode == lastCountryCode) {
            return;
          }

          lastCountryCode = countryCode;
          final currency = mapCountryToCurrency(countryCode, currencyData);

          onCurrencyChanged(currency);
        });
  }

  static void stopCurrencyListener() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
