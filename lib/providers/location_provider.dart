import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/location_model.dart';
import '../data/services/geocoding_service.dart';
import 'persona_provider.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

enum GpsPermissionStatus {
  notDetermined,
  serviceDisabled,
  denied,
  deniedForever,
  granted,
}

final gpsStatusProvider = StateProvider<GpsPermissionStatus>((ref) {
  return GpsPermissionStatus.notDetermined;
});

final isDetectingLocationProvider = StateProvider<bool>((ref) {
  return false;
});

class LocationNotifier extends StateNotifier<AsyncValue<LocationModel>> {
  final GeocodingService _geocoding;
  final Ref _ref;

  LocationNotifier(this._geocoding, this._ref)
      : super(const AsyncValue.loading()) {
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    final storage = _ref.read(storageServiceProvider);
    final lastLoc = await storage.loadLastLocation();
    if (lastLoc != null) {
      state = AsyncValue.data(lastLoc);
    } else {
      state = AsyncValue.data(LocationModel.defaultLocation());
    }
    // Attempt automatic detection on startup if permission is already available
    await autoDetectLocation(silent: true);
  }

  /// Automatically requests GPS permission and detects actual location.
  /// [silent] if true won't alter state to error if permission is not yet granted.
  Future<bool> autoDetectLocation({bool silent = false}) async {
    _ref.read(isDetectingLocationProvider.notifier).state = true;
    try {
      // 1. Check if device location service (GPS toggle) is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _ref.read(gpsStatusProvider.notifier).state =
            GpsPermissionStatus.serviceDisabled;
        _ref.read(isDetectingLocationProvider.notifier).state = false;
        return false;
      }

      // 2. Check current GPS permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // First ask for permission of GPS
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _ref.read(gpsStatusProvider.notifier).state =
              GpsPermissionStatus.denied;
          _ref.read(isDetectingLocationProvider.notifier).state = false;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _ref.read(gpsStatusProvider.notifier).state =
            GpsPermissionStatus.deniedForever;
        _ref.read(isDetectingLocationProvider.notifier).state = false;
        return false;
      }

      // 3. Permission granted: Automatically detect actual coordinates
      _ref.read(gpsStatusProvider.notifier).state = GpsPermissionStatus.granted;

      // Fast-path: check last known position first for quick response
      Position? position = await Geolocator.getLastKnownPosition();

      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );


      // 4. Reverse geocode to get actual city, country, and state
      final location = await _geocoding.reverseGeocode(
        position.latitude,
        position.longitude,
        isAutoDetected: true,
      );

      final storage = _ref.read(storageServiceProvider);
      await storage.saveLastLocation(location);

      state = AsyncValue.data(location);
      _ref.read(isDetectingLocationProvider.notifier).state = false;
      return true;
    } catch (e, stack) {
      debugPrint('📍 GPS / LOCATION ERROR: $e');
      debugPrint('$stack');
      _ref.read(isDetectingLocationProvider.notifier).state = false;
      if (!silent) {
        final storage = _ref.read(storageServiceProvider);
        final lastLoc = await storage.loadLastLocation();
        state = AsyncValue.data(lastLoc ?? LocationModel.defaultLocation());
      }
      return false;
    }
  }

  /// Manually sets a location (from city search).
  Future<void> setLocation(LocationModel location) async {
    state = AsyncValue.data(location.copyWith(isAutoDetected: false));
    final storage = _ref.read(storageServiceProvider);
    await storage.saveLastLocation(location);
  }

  /// Opens the device GPS location settings screen.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Opens application permissions settings.
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Refreshes the current location.
  Future<void> refresh() async {
    await autoDetectLocation(silent: false);
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<LocationModel>>((ref) {
  final geocoding = ref.watch(geocodingServiceProvider);
  return LocationNotifier(geocoding, ref);
});

class SavedCitiesNotifier extends StateNotifier<List<LocationModel>> {
  final Ref _ref;

  SavedCitiesNotifier(this._ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    final storage = _ref.read(storageServiceProvider);
    final list = await storage.loadSavedCities();
    state = list;
  }

  Future<void> addCity(LocationModel city) async {
    if (!state.any((c) => c.cityName == city.cityName)) {
      final updated = [...state, city];
      state = updated;
      final storage = _ref.read(storageServiceProvider);
      await storage.saveSavedCities(updated);
    }
  }

  Future<void> removeCity(String cityName) async {
    final updated = state.where((c) => c.cityName != cityName).toList();
    state = updated;
    final storage = _ref.read(storageServiceProvider);
    await storage.saveSavedCities(updated);
  }
}

final savedCitiesProvider =
    StateNotifierProvider<SavedCitiesNotifier, List<LocationModel>>((ref) {
  return SavedCitiesNotifier(ref);
});
