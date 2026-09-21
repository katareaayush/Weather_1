import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/location_provider.dart';

class LocationPermissionDialog extends ConsumerWidget {
  const LocationPermissionDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LocationPermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDetecting = ref.watch(isDetectingLocationProvider);
    final gpsStatus = ref.watch(gpsStatusProvider);

    String message =
        'Allow Mausam to access your device GPS to automatically detect your actual city and deliver real-time weather, AQI, and persona alerts for your exact location.';
    String actionLabel = 'Allow GPS & Detect Location 📍';
    IconData actionIcon = Icons.my_location_rounded;

    if (gpsStatus == GpsPermissionStatus.serviceDisabled) {
      message =
          'Location service is turned off on your device. Please turn on GPS in your device settings to enable automatic location detection.';
      actionLabel = 'Open Location Settings ⚙️';
      actionIcon = Icons.settings_rounded;
    } else if (gpsStatus == GpsPermissionStatus.deniedForever) {
      message =
          'Location permission is permanently denied. You can enable it in your phone App Settings to use automatic GPS detection.';
      actionLabel = 'Open App Settings ⚙️';
      actionIcon = Icons.settings_applications_rounded;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181F2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E88E5).withOpacity(0.12),
            ),
            child: const Icon(
              Icons.location_searching_rounded,
              size: 36,
              color: Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            'Automatic Location Detection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Primary Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isDetecting
                  ? null
                  : () async {
                      final notifier = ref.read(locationProvider.notifier);

                      if (gpsStatus == GpsPermissionStatus.serviceDisabled) {
                        await notifier.openLocationSettings();
                        return;
                      }
                      if (gpsStatus == GpsPermissionStatus.deniedForever) {
                        await notifier.openAppSettings();
                        return;
                      }

                      final success = await notifier.autoDetectLocation();
                      if (context.mounted) {
                        if (success) {
                          Navigator.pop(context, true);
                          final loc = ref.read(locationProvider).valueOrNull;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF2E7D32),
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Location detected: ${loc?.cityName ?? 'Current Location'}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Feedback if denied
                          final updatedStatus = ref.read(gpsStatusProvider);
                          if (updatedStatus ==
                              GpsPermissionStatus.serviceDisabled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please turn on GPS on your device.'),
                              ),
                            );
                          }
                        }
                      }
                    },
              icon: isDetecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Icon(actionIcon, size: 20),
              label: Text(
                isDetecting ? 'Detecting your actual location...' : actionLabel,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Secondary Dismiss Button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Search Manually Instead',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
