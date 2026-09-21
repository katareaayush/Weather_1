import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/place_suggestion_model.dart';
import '../data/services/place_suggestion_service.dart';
import 'persona_provider.dart';
import 'weather_provider.dart';

final placeSuggestionServiceProvider = Provider<PlaceSuggestionService>((ref) {
  return const PlaceSuggestionService();
});

final placeSuggestionsProvider = Provider<List<PlaceSuggestionModel>>((ref) {
  final persona = ref.watch(personaProvider);
  final weatherBundleAsync = ref.watch(weatherDataProvider);
  final service = ref.watch(placeSuggestionServiceProvider);

  final bundle = weatherBundleAsync.valueOrNull ?? MausamDataBundle.mock();

  return service.getSuggestions(
    persona: persona,
    cityName: bundle.location.cityName,
    weather: bundle.weather,
    airQuality: bundle.airQuality,
    marine: bundle.marine,
  );
});
