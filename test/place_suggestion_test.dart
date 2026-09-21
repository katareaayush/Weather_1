import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/core/constants/personas.dart';
import 'package:mausam/data/models/weather_model.dart';
import 'package:mausam/data/models/air_quality_model.dart';
import 'package:mausam/data/models/marine_model.dart';
import 'package:mausam/data/services/place_suggestion_service.dart';

void main() {
  group('PlaceSuggestionService for all 8 Personas', () {
    const service = PlaceSuggestionService();
    final weather = WeatherModel.mock();
    final aqi = AirQualityModel.mock();
    final marine = MarineModel.mock();

    test('should return valid curated suggestions for Mumbai across all 8 personas', () {
      for (final persona in Personas.all) {
        final suggestions = service.getSuggestions(
          persona: persona,
          cityName: 'Mumbai',
          weather: weather,
          airQuality: aqi,
          marine: marine,
        );

        expect(suggestions.isNotEmpty, true,
            reason: 'Persona $persona in Mumbai should have suggestions');
        final top = suggestions.first;
        expect(top.name.isNotEmpty, true);
        expect(top.suitabilityScore, greaterThanOrEqualTo(50));
        expect(top.suitabilityScore, lessThanOrEqualTo(100));
        expect(top.mapsQuery.isNotEmpty, true);
        expect(top.bestTimeToVisit.isNotEmpty, true);
        expect(top.weatherMatchReason.isNotEmpty, true);
      }
    });

    test('should dynamically generate valid suggestions for any detected city across all 8 personas', () {
      const dynamicCity = 'Geneva';
      for (final persona in Personas.all) {
        final suggestions = service.getSuggestions(
          persona: persona,
          cityName: dynamicCity,
          weather: weather,
          airQuality: aqi,
          marine: marine,
        );

        expect(suggestions.isNotEmpty, true,
            reason: 'Persona $persona in $dynamicCity should have suggestions');
        final top = suggestions.first;
        expect(top.name.contains(dynamicCity), true,
            reason: 'Dynamic suggestion should incorporate detected city name');
        expect(top.suitabilityScore, greaterThanOrEqualTo(40));
        expect(top.mapsQuery.contains(dynamicCity), true);
      }
    });

    test('health persona suggestions adapt score based on AQI', () {
      const goodAirQuality = AirQualityModel(
        aqi: 20,
        pm25: 5.0,
        pm10: 10.0,
        no2: 8.0,
        o3: 15.0,
        grassPollen: 2.0,
        treePollen: 1.0,
        weedPollen: 0.0,
        uvIndex: 2.0,
      );

      const poorAirQuality = AirQualityModel(
        aqi: 180,
        pm25: 120.0,
        pm10: 200.0,
        no2: 45.0,
        o3: 70.0,
        grassPollen: 25.0,
        treePollen: 40.0,
        weedPollen: 15.0,
        uvIndex: 8.0,
      );

      final goodSuggestions = service.getSuggestions(
        persona: Personas.health,
        cityName: 'Reykjavik',
        weather: weather,
        airQuality: goodAirQuality,
        marine: marine,
      );

      final poorSuggestions = service.getSuggestions(
        persona: Personas.health,
        cityName: 'Reykjavik',
        weather: weather,
        airQuality: poorAirQuality,
        marine: marine,
      );

      expect(goodSuggestions.first.suitabilityScore,
          greaterThan(poorSuggestions.first.suitabilityScore));
    });
  });
}
