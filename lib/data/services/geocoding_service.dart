import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/location_model.dart';

class GeocodingService {
  final Dio _dio;

  GeocodingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                headers: {
                  'User-Agent': 'MausamApp/1.0 (contact@mausam.app)',
                },
              ),
            );

  /// Reverse geocodes latitude/longitude to a readable city and country.
  Future<LocationModel> reverseGeocode(double lat, double lon,
      {bool isAutoDetected = true}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.nominatimReverse,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
          'zoom': 10,
          'accept-language': 'en',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? {};

      final city = address['city'] ??
          address['town'] ??
          address['suburb'] ??
          address['city_district'] ??
          address['district'] ??
          address['village'] ??
          address['municipality'] ??
          address['county'] ??
          address['state_district'] ??
          address['state'] ??
          'Current Location';

      final country = address['country'] ?? '';
      final state = address['state'] as String?;

      return LocationModel(
        latitude: lat,
        longitude: lon,
        cityName: city.toString(),
        country: country.toString(),
        state: state,
        isAutoDetected: isAutoDetected,
      );
    } catch (_) {
      // Fallback: try BigDataCloud client reverse geocode
      try {
        final bdcResponse = await _dio.get(
          'https://api.bigdatacloud.net/data/reverse-geocode-client',
          queryParameters: {
            'latitude': lat,
            'longitude': lon,
            'localityLanguage': 'en',
          },
        );
        final bdcData = bdcResponse.data as Map<String, dynamic>;
        final city = bdcData['city'] ??
            bdcData['locality'] ??
            bdcData['principalSubdivision'] ??
            'Current Location';
        final country = bdcData['countryName'] ?? '';
        final state = bdcData['principalSubdivision'] as String?;

        return LocationModel(
          latitude: lat,
          longitude: lon,
          cityName: city.toString(),
          country: country.toString(),
          state: state,
          isAutoDetected: isAutoDetected,
        );
      } catch (_) {
        return LocationModel(
          latitude: lat,
          longitude: lon,
          cityName: 'Current Location',
          country: '',
          isAutoDetected: isAutoDetected,
        );
      }
    }
  }

  /// Searches cities using Open-Meteo's free geocoding API.
  Future<List<LocationModel>> searchCity(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get(
        ApiEndpoints.geocodingBase,
        queryParameters: {
          'name': query.trim(),
          'count': 6,
          'language': 'en',
          'format': 'json',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      return results.map((item) {
        final map = item as Map<String, dynamic>;
        return LocationModel(
          latitude: (map['latitude'] as num).toDouble(),
          longitude: (map['longitude'] as num).toDouble(),
          cityName: map['name'] as String? ?? 'Unknown',
          country: map['country'] as String? ?? '',
          state: map['admin1'] as String?,
          isAutoDetected: false,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
