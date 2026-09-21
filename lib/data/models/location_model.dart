class LocationModel {
  final double latitude;
  final double longitude;
  final String cityName;
  final String country;
  final String? state;
  final bool isAutoDetected;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.country = '',
    this.state,
    this.isAutoDetected = false,
  });

  factory LocationModel.defaultLocation() {
    return const LocationModel(
      latitude: 19.0760,
      longitude: 72.8777,
      cityName: 'Mumbai',
      country: 'India',
      state: 'Maharashtra',
      isAutoDetected: false,
    );
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    String? country,
    String? state,
    bool? isAutoDetected,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      state: state ?? this.state,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'cityName': cityName,
        'country': country,
        'state': state,
        'isAutoDetected': isAutoDetected,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        cityName: json['cityName'] as String? ?? 'Unknown',
        country: json['country'] as String? ?? '',
        state: json['state'] as String?,
        isAutoDetected: json['isAutoDetected'] as bool? ?? false,
      );

  @override
  String toString() =>
      '$cityName, $country ($latitude, $longitude, auto: $isAutoDetected)';
}
