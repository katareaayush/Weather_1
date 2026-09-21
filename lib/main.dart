import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Gracefully load .env — app must NOT crash if .env is missing or malformed.
  // All core APIs (Open-Meteo, Nominatim) are free and require no keys.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env file not loaded (this is OK — no API keys required): $e');
  }

  runApp(
    const ProviderScope(
      child: MausamApp(),
    ),
  );
}
