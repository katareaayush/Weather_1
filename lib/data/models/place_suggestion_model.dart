class PlaceSuggestionModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String addressOrArea;
  final int suitabilityScore; // 0 - 100
  final String weatherMatchReason;
  final String bestTimeToVisit;
  final List<String> highlights;
  final String emoji;
  final String mapsQuery;

  const PlaceSuggestionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.addressOrArea,
    required this.suitabilityScore,
    required this.weatherMatchReason,
    required this.bestTimeToVisit,
    required this.highlights,
    required this.emoji,
    required this.mapsQuery,
  });
}
