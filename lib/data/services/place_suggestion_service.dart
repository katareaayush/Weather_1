import '../../core/constants/personas.dart';
import '../../core/utils/weather_helpers.dart';
import '../models/weather_model.dart';
import '../models/air_quality_model.dart';
import '../models/marine_model.dart';
import '../models/place_suggestion_model.dart';

class PlaceSuggestionService {
  const PlaceSuggestionService();

  List<PlaceSuggestionModel> getSuggestions({
    required String persona,
    required String cityName,
    required WeatherModel weather,
    required AirQualityModel airQuality,
    required MarineModel marine,
  }) {
    final cleanCity = cityName.trim().isEmpty ? 'Your City' : cityName.trim();
    final lowerCity = cleanCity.toLowerCase();

    // Check if we have predefined real iconic spots for major cities
    if (lowerCity.contains('mumbai')) {
      return _getMumbaiSuggestions(persona, weather, airQuality, marine);
    } else if (lowerCity.contains('delhi')) {
      return _getDelhiSuggestions(persona, weather, airQuality, marine);
    } else if (lowerCity.contains('bengaluru') || lowerCity.contains('bangalore')) {
      return _getBengaluruSuggestions(persona, weather, airQuality, marine);
    } else if (lowerCity.contains('london')) {
      return _getLondonSuggestions(persona, weather, airQuality, marine);
    } else if (lowerCity.contains('new york')) {
      return _getNewYorkSuggestions(persona, weather, airQuality, marine);
    } else if (lowerCity.contains('dubai')) {
      return _getDubaiSuggestions(persona, weather, airQuality, marine);
    }

    // Dynamic, city-aware place suggestions for any city detected via GPS or search
    return _generateDynamicCitySuggestions(
      persona: persona,
      cityName: cleanCity,
      weather: weather,
      airQuality: airQuality,
      marine: marine,
    );
  }

  // ---------------------------------------------------------------------------
  // Dynamic City Suggestion Engine
  // ---------------------------------------------------------------------------
  List<PlaceSuggestionModel> _generateDynamicCitySuggestions({
    required String persona,
    required String cityName,
    required WeatherModel weather,
    required AirQualityModel airQuality,
    required MarineModel marine,
  }) {
    switch (persona) {
      case Personas.health:
        final aqi = airQuality.aqi;
        final score = (100 - (aqi * 0.4)).clamp(50, 99).toInt();
        return [
          PlaceSuggestionModel(
            id: 'health_1',
            name: '$cityName Botanical Gardens & Pine Forest',
            category: 'Oxygen-Rich Eco Belt',
            description:
                'Dense canopy park with high tree density filtering urban particulate matter. Best for asthma recovery and deep breathing exercises.',
            addressOrArea: 'Central Eco Green Corridor, $cityName',
            suitabilityScore: score,
            weatherMatchReason:
                'Current AQI ($aqi) is buffered by 40% higher oxygenation and shaded foliage.',
            bestTimeToVisit: '06:00 AM – 08:30 AM (Peak Oxygen Hours)',
            highlights: ['Zero Vehicle Zone', 'Herbal Walking Track', 'Shaded Benches', 'Clean Air Monitors'],
            emoji: '🌲',
            mapsQuery: 'Botanical Gardens in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'health_2',
            name: '$cityName Eco Wetland Lake & Jogging Ridge',
            category: 'Lakeside Fresh Air Zone',
            description:
                'Open water body creates natural micro-breezes that disperse dust and ground-level allergens.',
            addressOrArea: 'North Lake District, $cityName',
            suitabilityScore: (score - 4).clamp(40, 95).toInt(),
            weatherMatchReason:
                'Natural lake humidity (${weather.humidity.round()}%) helps soothe dry airways and skin.',
            bestTimeToVisit: '05:30 PM – 07:00 PM',
            highlights: ['Waterfront Breeze', 'Low Pollen Corridor', 'Restroom Access'],
            emoji: '💧',
            mapsQuery: 'Nature Park Lake in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'health_3',
            name: '$cityName Hilltop Ridge Trail',
            category: 'High-Altitude Clean Air',
            description:
                'Elevated vantage point above thermal inversion layers, offering fresher airflow away from traffic fumes.',
            addressOrArea: 'Hilltop Forest Reserve, $cityName',
            suitabilityScore: (score - 7).clamp(40, 92).toInt(),
            weatherMatchReason:
                'Gentle breeze (${weather.windSpeed.round()} km/h) prevents stagnant air pockets.',
            bestTimeToVisit: 'Early Morning Sunrise',
            highlights: ['Panoramic Viewpoint', 'Natural Elevation', 'Low Smog Risk'],
            emoji: '⛰️',
            mapsQuery: 'Hill Ridge Park in $cityName',
          ),
        ];

      case Personas.fitness:
        final runScore = WeatherHelpers.runScore(weather);
        return [
          PlaceSuggestionModel(
            id: 'fitness_1',
            name: '$cityName Riverside Athletic Track & Promenade',
            category: 'Continuous Paved Running Trail',
            description:
                'Continuous 5km asphalt and rubberized running loop with distance markers and lighting, free from traffic intersections.',
            addressOrArea: 'Riverfront Boulevard, $cityName',
            suitabilityScore: runScore,
            weatherMatchReason:
                'Current wind of ${weather.windSpeed.round()} km/h and ${weather.currentTemp.round()}°C temperature provide low resistance.',
            bestTimeToVisit: '06:00 AM – 08:00 AM or 06:00 PM – 07:30 PM',
            highlights: ['Rubberized Track', 'Distance Markers every 500m', 'Water Refill Stations', 'Night Floodlights'],
            emoji: '🏃',
            mapsQuery: 'Running Track Promenade in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'fitness_2',
            name: '$cityName Central Sports Arena & Stadium Loop',
            category: 'Regulated Outdoor Fitness Grounds',
            description:
                'Olympic standard 400m synthetic track with calisthenics workout stations, pull-up bars, and stretching turf.',
            addressOrArea: 'Sports Complex Road, $cityName',
            suitabilityScore: (runScore - 3).clamp(40, 96).toInt(),
            weatherMatchReason:
                'Stadium walls provide wind protection if gusts exceed 25 km/h.',
            bestTimeToVisit: '06:30 AM – 09:00 AM',
            highlights: ['400m Synthetic Track', 'Outdoor Calisthenics Gym', 'Locker Amenities', 'First Aid Post'],
            emoji: '🏟️',
            mapsQuery: 'Stadium Track in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'fitness_3',
            name: '$cityName Municipal Forest Park Trail',
            category: 'Shaded Cross-Country Trail',
            description:
                'Natural packed dirt trail under broad-leaf trees, protecting runners from UV rays during sunny hours.',
            addressOrArea: 'Greenwood Forest Park, $cityName',
            suitabilityScore: (runScore - 6).clamp(35, 93).toInt(),
            weatherMatchReason:
                'Canopy reduces feels-like heat by 3–4°C compared to open asphalt.',
            bestTimeToVisit: '07:00 AM – 09:30 AM',
            highlights: ['Dirt Terrain (Low Joint Impact)', 'Natural Canopy Shade', 'Hill Incline Intervals'],
            emoji: '🌲',
            mapsQuery: 'Trail Park in $cityName',
          ),
        ];

      case Personas.beach:
        final wave = marine.waveHeight;
        final safe = wave <= 1.5 && weather.windSpeed <= 30;
        final score = safe ? 94 : 68;
        return [
          PlaceSuggestionModel(
            id: 'beach_1',
            name: '$cityName Coastal Sunset Bay & Beach',
            category: 'Protected Swimming Bay & Surf',
            description:
                'Sheltered coastal crescent with lifeguards on duty, designated swimming zones, and soft golden sand.',
            addressOrArea: 'Marine Shoreline Drive, $cityName',
            suitabilityScore: score,
            weatherMatchReason:
                'Wave height is ${wave.toStringAsFixed(1)}m with ${marine.seaTemperature.round()}°C water temperature.',
            bestTimeToVisit: '04:30 PM – 06:45 PM (Sunset Glow)',
            highlights: ['Lifeguard Tower On-Duty', 'Clean Water Zone', 'Beach Volleyball Court', 'Showers & Changing Rooms'],
            emoji: '🏖️',
            mapsQuery: 'Beach in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'beach_2',
            name: '$cityName Surf Point & Breakwater Pier',
            category: 'Surfing & Watersports Hub',
            description:
                'Point break attracting clean swells with optimal wave peel and board rental shops along the esplanade.',
            addressOrArea: 'Lighthouse Point, $cityName',
            suitabilityScore: wave > 1.0 ? 92 : 72,
            weatherMatchReason:
                'Wave period is ${marine.wavePeriod.round()}s with ${marine.swellWaveDirection.round()}° swell angle.',
            bestTimeToVisit: 'Early Morning High Tide',
            highlights: ['Surf Board Rentals', 'Windsurf & Kayaks', 'Scenic Pier Walkway'],
            emoji: '🏄',
            mapsQuery: 'Surfing Beach in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'beach_3',
            name: '$cityName Waterfront Marine Promenade',
            category: 'Coastal Walking & Cycling Bay',
            description:
                'Wide pedestrian seaside promenade for strolling, sunset watching, and ocean breeze without getting into the surf.',
            addressOrArea: 'Harbor Coastal Walk, $cityName',
            suitabilityScore: 90,
            weatherMatchReason:
                'UV index (${weather.uvIndex.toStringAsFixed(1)}) is gentle late in the afternoon.',
            bestTimeToVisit: '05:00 PM – 08:00 PM',
            highlights: ['Bicycle Track', 'Seaside Cafes', 'Sunset Photography Vantage'],
            emoji: '🌊',
            mapsQuery: 'Coastal Promenade in $cityName',
          ),
        ];

      case Personas.traveler:
        return [
          PlaceSuggestionModel(
            id: 'traveler_1',
            name: '$cityName Heritage Fort & Sky Observatory',
            category: 'Iconic Historic Landmark & Viewpoint',
            description:
                'The crown jewel tourist destination of $cityName. Offers 360-degree panoramic skyline views and cultural exhibits.',
            addressOrArea: 'Old Historic Citadel, $cityName',
            suitabilityScore: 95,
            weatherMatchReason:
                'Current visibility of ${(weather.visibility / 1000).toStringAsFixed(1)} km ensures crystal clear panoramic photography.',
            bestTimeToVisit: '10:00 AM – 01:00 PM or 04:30 PM for Sunset',
            highlights: ['Architectural Photography', 'Audio Guided Tour', 'Souvenir Emporium', 'Rooftop Cafe'],
            emoji: '🏰',
            mapsQuery: 'Historical Landmark in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'traveler_2',
            name: '$cityName Grand Central Esplanade & Plaza',
            category: 'Cultural Hub & Public Square',
            description:
                'Vibrant civic square surrounded by museums, street food bazaars, craft markets, and colonial or heritage architecture.',
            addressOrArea: 'City Center Mall & Plaza, $cityName',
            suitabilityScore: 91,
            weatherMatchReason:
                'No heavy rain expected (${weather.precipitationProbability.round()}% prob), comfortable for walking.',
            bestTimeToVisit: '11:00 AM – 06:00 PM',
            highlights: ['Street Food Walking Tours', 'Local Handicrafts', 'Live Street Musicians', 'Transit Hub Connected'],
            emoji: '🏛️',
            mapsQuery: 'City Center Plaza in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'traveler_3',
            name: '$cityName Scenic Sky Deck & High Observation Point',
            category: 'Skyline Observation Deck',
            description:
                'High-altitude observation terrace overlooking the entire cityscape, mountain backdrop, and harbors.',
            addressOrArea: 'Skyline Tower 52nd Floor, $cityName',
            suitabilityScore: 89,
            weatherMatchReason:
                'Weather condition (${WeatherHelpers.codeToDescription(weather.weatherCode)}) allows wide skyline clarity.',
            bestTimeToVisit: 'Twilight Golden Hour (05:45 PM)',
            highlights: ['Glass Bottom Walk', 'Telescope Viewers', 'Fine Dining Cocktails'],
            emoji: '🌆',
            mapsQuery: 'Observation Deck in $cityName',
          ),
        ];

      case Personas.family:
        final hasRain = weather.precipitationProbability > 50;
        return [
          PlaceSuggestionModel(
            id: 'family_1',
            name: '$cityName Children’s Adventure Lake & Meadow Park',
            category: 'Fenced Playground & Picnic Lawns',
            description:
                'Safe, family-friendly wonderland featuring rubber-cushioned playground slides, sandbox, paddle boating lake, and shaded lawns.',
            addressOrArea: 'Family Recreation Park, $cityName',
            suitabilityScore: hasRain ? 65 : 96,
            weatherMatchReason: hasRain
                ? 'Rain risk present: park has 3 covered pavilions and indoor activity center.'
                : 'Dry lawn conditions and moderate UV (${weather.uvIndex.toStringAsFixed(1)}) for outdoor playing.',
            bestTimeToVisit: '09:30 AM – 12:30 PM or 04:00 PM – 06:30 PM',
            highlights: ['Fenced Toddler Zone', 'Soft Rubber Flooring', 'Paddle Boats', 'Clean Baby Care Facilities'],
            emoji: '🛝',
            mapsQuery: 'Children Park in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'family_2',
            name: '$cityName Science Discovery Centre & Interactive Garden',
            category: 'Educational Family Edutainment',
            description:
                'Hands-on interactive science exhibits, dinosaur outdoor maze, butterfly garden, and 3D planetarium theater.',
            addressOrArea: 'Museum Avenue, $cityName',
            suitabilityScore: 94,
            weatherMatchReason:
                'Climate-controlled indoor zones provide perfect backup if afternoon temperature climbs to ${weather.currentTemp.round() + 3}°C.',
            bestTimeToVisit: '11:00 AM – 04:00 PM',
            highlights: ['Hands-on Science Lab', 'Butterfly Conservatory', 'Kids Cafeteria', 'Stroller Friendly'],
            emoji: '🔬',
            mapsQuery: 'Science Centre in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'family_3',
            name: '$cityName Animal Zoological Safari & Garden',
            category: 'Wildlife Walk & Shaded Woods',
            description:
                'Sprawling botanical zoological park where kids can observe animals in naturalistic enclosures with electric tram rides.',
            addressOrArea: 'Zoo Park Road, $cityName',
            suitabilityScore: 88,
            weatherMatchReason:
                'Overcast/cool breezes make walking the 3km animal safari pleasant for all ages.',
            bestTimeToVisit: '09:00 AM – 11:30 AM',
            highlights: ['Electric Tram Tour', 'Petting Zoo', 'Ice Cream Kiosks', 'Wide Shaded Walkways'],
            emoji: '🦒',
            mapsQuery: 'Zoo in $cityName',
          ),
        ];

      case Personas.agriculture:
        final frost = weather.daily.any((d) => d.tempMin <= 2.0);
        return [
          PlaceSuggestionModel(
            id: 'agri_1',
            name: '$cityName Community Allotment Gardens & Farm',
            category: 'Organic Urban Farming Hub',
            description:
                'Civic permaculture demonstration farm with community plots, organic compost centers, and heirloom seed exchange banks.',
            addressOrArea: 'Agri Ecology Park, $cityName',
            suitabilityScore: frost ? 70 : 95,
            weatherMatchReason:
                'Soil moisture at ${(weather.daily.isNotEmpty ? weather.daily.first.soilMoisture : 35).round()}% is in the prime zone for transplanting.',
            bestTimeToVisit: '07:00 AM – 10:30 AM',
            highlights: ['Composting Workshops', 'Heirloom Seed Bank', 'Soil pH Testing Station', 'Tool Share Library'],
            emoji: '🌱',
            mapsQuery: 'Community Garden in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'agri_2',
            name: '$cityName Horticultural Research Nursery',
            category: 'Plant Nursery & Greenhouses',
            description:
                'Specialized greenhouses providing native climate-resilient saplings, fruit trees, fertilizers, and greenhouse consultations.',
            addressOrArea: 'Plantation Sector, $cityName',
            suitabilityScore: 92,
            weatherMatchReason:
                'Seasonal planting guidance active for current month and local microclimate.',
            bestTimeToVisit: '08:00 AM – 01:00 PM',
            highlights: ['Native Seedlings', 'Drip Irrigation Supplies', 'Agronomist Helpdesk', 'Cold-Frame Supplies'],
            emoji: '🪴',
            mapsQuery: 'Plant Nursery in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'agri_3',
            name: '$cityName Farmers Market & Organic Produce Yard',
            category: 'Direct Farmer Exchange & Grain Yard',
            description:
                'Local growers market where farmers and backyard gardeners trade seeds, seasonal produce, and organic compost.',
            addressOrArea: 'Market Square, $cityName',
            suitabilityScore: 90,
            weatherMatchReason:
                'Dry weather (${weather.precipitationProbability.round()}% rain risk) ideal for outdoor grain and seed trading.',
            bestTimeToVisit: 'Early Weekend Mornings',
            highlights: ['Organic Manure', 'Fresh Harvest', 'Garden Tool Vendors'],
            emoji: '🌾',
            mapsQuery: 'Farmers Market in $cityName',
          ),
        ];

      case Personas.commuter:
        final fog = WeatherHelpers.isFog(weather.weatherCode);
        return [
          PlaceSuggestionModel(
            id: 'commute_1',
            name: '$cityName Express Transit Skywalk & Metro Corridor',
            category: 'Weather-Protected Commuter Transit Hub',
            description:
                'Elevated air-conditioned skywalk connecting central metro lines, regional buses, and taxi stands with zero road crossing.',
            addressOrArea: 'Central Terminal Intermodal, $cityName',
            suitabilityScore: 97,
            weatherMatchReason:
                'Fully covered pedestrian tunnels protect against ${fog ? "thick morning fog" : "unpredictable road slickness"}.',
            bestTimeToVisit: '07:30 AM – 09:30 AM & 05:00 PM – 07:30 PM',
            highlights: ['Covered Skywalk', 'Real-time Transit Screens', 'Park & Ride Deck', 'Direct Metro Interchanges'],
            emoji: '🚇',
            mapsQuery: 'Central Transit Station in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'commute_2',
            name: '$cityName Outer Ring Expressway Bypass',
            category: 'High-Speed Signal-Free Corridor',
            description:
                'Wide multi-lane elevated highway bypass with anti-skid tarmac, overhead drainage culverts, and dynamic speed signage.',
            addressOrArea: 'Outer Bypass Corridor, $cityName',
            suitabilityScore: fog ? 65 : 92,
            weatherMatchReason:
                'Road visibility is ${(weather.visibility / 1000).toStringAsFixed(1)} km with smooth traffic flow.',
            bestTimeToVisit: 'Non-Peak Hours (10:30 AM – 04:00 PM)',
            highlights: ['Anti-Hydroplaning Tarmac', 'LED Fog Warning Boards', 'Emergency SOS Bays'],
            emoji: '🛣️',
            mapsQuery: 'Expressway Bypass in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'commute_3',
            name: '$cityName Park & Ride Eco Metro Terminal',
            category: 'Multimodal Commuter Station',
            description:
                'Spacious multi-level park-and-ride facility where commuters leave cars to avoid city center traffic jams and wet roads.',
            addressOrArea: 'Gateway Metro Terminal, $cityName',
            suitabilityScore: 90,
            weatherMatchReason:
                'Secure covered parking protects vehicles from rain and extreme heat.',
            bestTimeToVisit: '07:00 AM – 09:00 AM',
            highlights: ['EV Fast Chargers', 'Covered Parking', 'Direct Rapid Transit'],
            emoji: '🅿️',
            mapsQuery: 'Metro Park and Ride in $cityName',
          ),
        ];

      case Personas.event:
        final hasRain = weather.precipitationProbability > 40;
        return [
          PlaceSuggestionModel(
            id: 'event_1',
            name: '$cityName Grand Lakeside Lawns & Pavilion',
            category: 'Outdoor Wedding & Gala Lawn',
            description:
                'Sprawling landscaped lakeside lawns with built-in waterproof marquees, manicured turf drainage, and architectural night lighting.',
            addressOrArea: 'Lakeside Club Road, $cityName',
            suitabilityScore: hasRain ? 72 : 98,
            weatherMatchReason: hasRain
                ? 'Rain probability is ${weather.precipitationProbability.round()}%: glass pavilion provides full shelter for 500+ guests.'
                : 'Current temperature (${weather.currentTemp.round()}°C) and clear skies offer an unforgettable outdoor evening.',
            bestTimeToVisit: '05:30 PM – 11:00 PM (Cocktail & Dinner)',
            highlights: ['High-Capacity Rain Shelter', 'Engineered Turf Drainage', 'Banquet Kitchen Infrastructure', 'Valet Parking for 300+ Cars'],
            emoji: '💍',
            mapsQuery: 'Wedding Lawns in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'event_2',
            name: '$cityName Heritage Courtyard & Amphitheatre',
            category: 'Open-Air Cultural & Party Amphitheatre',
            description:
                'Tiered stone amphitheatre with historic colonnades, acoustic stage, and banquet lawns for corporate galas and concerts.',
            addressOrArea: 'Cultural Complex Sector, $cityName',
            suitabilityScore: hasRain ? 65 : 93,
            weatherMatchReason:
                'Wind speed of ${weather.windSpeed.round()} km/h is below banquet disturbance limits.',
            bestTimeToVisit: '06:00 PM – 10:30 PM',
            highlights: ['Acoustic Shell Stage', 'Stone Tiered Seating', 'Green Room Suites', 'Sound & Light Equipment Ready'],
            emoji: '🎭',
            mapsQuery: 'Open Air Amphitheatre in $cityName',
          ),
          PlaceSuggestionModel(
            id: 'event_3',
            name: '$cityName Skyview Rooftop Terrace & Lounge',
            category: 'Elevated Private Party Venue',
            description:
                'Retractable glass-roof terrace offering 360-degree city views, outdoor bar, and climate-controlled indoor lounge.',
            addressOrArea: 'Downtown Hospitality District, $cityName',
            suitabilityScore: 91,
            weatherMatchReason:
                'Retractable glass roof guarantees zero event disruption in case of sudden weather shifts.',
            bestTimeToVisit: '07:00 PM – 12:00 AM',
            highlights: ['Retractable Glass Enclosure', 'Panoramic Skyline View', 'Full Bar & DJ Setup', 'Climate Controlled'],
            emoji: '🍸',
            mapsQuery: 'Rooftop Event Venue in $cityName',
          ),
        ];

      default:
        return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Predefined Iconic Spots for Major Cities (e.g. Mumbai)
  // ---------------------------------------------------------------------------
  List<PlaceSuggestionModel> _getMumbaiSuggestions(
    String persona,
    WeatherModel weather,
    AirQualityModel airQuality,
    MarineModel marine,
  ) {
    switch (persona) {
      case Personas.fitness:
        return [
          PlaceSuggestionModel(
            id: 'mumbai_fit_1',
            name: 'Marine Drive Promenade (Queen\'s Necklace)',
            category: 'Iconic Coastal Running Strip',
            description:
                '3.6km continuous wide sea-facing promenade from Nariman Point to Girgaon Chowpatty. The premier running spot in Mumbai.',
            addressOrArea: 'Marine Drive, South Mumbai',
            suitabilityScore: WeatherHelpers.runScore(weather),
            weatherMatchReason:
                'Morning ocean breeze keeps apparent temp down despite Mumbai humidity.',
            bestTimeToVisit: '05:30 AM – 08:00 AM',
            highlights: ['3.6km Continuous Strip', 'Ocean Breeze', 'Zero Signal Crossings', 'Running Community'],
            emoji: '🏃',
            mapsQuery: 'Marine Drive Promenade Mumbai',
          ),
          const PlaceSuggestionModel(
            id: 'mumbai_fit_2',
            name: 'Shivaji Park Jogging Track',
            category: 'Historic Athletic Turf & Dirt Loop',
            description:
                'Legendary 1.2km circular red-clay walking and running track lined with dense rain trees, cushioned for running joints.',
            addressOrArea: 'Dadar West, Mumbai',
            suitabilityScore: 92,
            weatherMatchReason:
                'Ancient mahogany trees provide continuous shade during early sun.',
            bestTimeToVisit: '06:00 AM – 08:30 AM',
            highlights: ['Cushioned Clay Track', 'Centenary Tree Shade', 'Open Gym Stations', 'Hydration Stalls'],
            emoji: '🌳',
            mapsQuery: 'Shivaji Park Dadar Mumbai',
          ),
          const PlaceSuggestionModel(
            id: 'mumbai_fit_3',
            name: 'Carter Road Promenade & Dog Park',
            category: 'Waterfront Sunset Trail',
            description:
                'Breezy 1.8km seaside path in Bandra with fitness stations, gazebos, and clean sea vistas.',
            addressOrArea: 'Bandra West, Mumbai',
            suitabilityScore: 89,
            weatherMatchReason:
                'Ideal for evening tempo runs as sea breeze picks up after 5:30 PM.',
            bestTimeToVisit: '05:30 PM – 07:30 PM',
            highlights: ['Sunset Sea View', 'Outdoor Calisthenics', 'Pet Friendly'],
            emoji: '👟',
            mapsQuery: 'Carter Road Promenade Bandra Mumbai',
          ),
        ];

      case Personas.health:
        return [
          const PlaceSuggestionModel(
            id: 'mumbai_health_1',
            name: 'Sanjay Gandhi National Park (SGNP) Eco Trail',
            category: 'Lungs of Mumbai — Clean Air Wilderness',
            description:
                'Sprawling 103 sq km tropical forest with AQI significantly lower than urban Mumbai. Kanheri caves trail offers pristine oxygenation.',
            addressOrArea: 'Borivali East, Mumbai',
            suitabilityScore: 96,
            weatherMatchReason:
                'Forest canopy reduces PM2.5 by up to 45% compared to suburban highways.',
            bestTimeToVisit: '06:30 AM – 09:30 AM',
            highlights: ['Lowest AQI in City', 'Dense Evergreen Canopy', 'Deer & Butterfly Habitat', 'Natural Stream Trails'],
            emoji: '🌲',
            mapsQuery: 'Sanjay Gandhi National Park Borivali Mumbai',
          ),
          const PlaceSuggestionModel(
            id: 'mumbai_health_2',
            name: 'Priyadarshini Park & Sports Complex',
            category: 'Sea-Facing Oxygen Garden',
            description:
                '20-acre lush green seaside sanctuary in Malabar Hill with thousands of planted trees and unobstructed sea air.',
            addressOrArea: 'Nepean Sea Road, Malabar Hill, Mumbai',
            suitabilityScore: 93,
            weatherMatchReason:
                'Direct Arabian Sea onshore breezes clear out urban particulate matter.',
            bestTimeToVisit: '06:00 AM – 08:30 AM',
            highlights: ['Direct Maritime Air', 'Olympic Running Track', 'Yoga Lawns', 'Zero Commercial Stalls'],
            emoji: '🌿',
            mapsQuery: 'Priyadarshini Park Malabar Hill Mumbai',
          ),
          const PlaceSuggestionModel(
            id: 'mumbai_health_3',
            name: 'Hanging Gardens & Kamala Nehru Ridge',
            category: 'Hilltop Clean Air Haven',
            description:
                'Terraced gardens perched at the top of Malabar Hill providing clean breezes and lush tree cover overlooking the bay.',
            addressOrArea: 'Ridge Road, Malabar Hill, Mumbai',
            suitabilityScore: 90,
            weatherMatchReason:
                'Altitude puts you above dense ground-level vehicle exhaust layers.',
            bestTimeToVisit: 'Early Morning or Sunset',
            highlights: ['Flower Clock & Topiary', 'Bay Vistas', 'Shaded Walking Paths'],
            emoji: '🌺',
            mapsQuery: 'Hanging Gardens Mumbai',
          ),
        ];

      case Personas.beach:
        return [
          PlaceSuggestionModel(
            id: 'mumbai_beach_1',
            name: 'Versova Surf Point & Rocky Shore',
            category: 'Surfing & Swell Beach',
            description:
                'The center of Mumbai\'s emerging surf culture. Community beach clean-up hub with gentle morning rolling waves.',
            addressOrArea: 'Versova, Andheri West, Mumbai',
            suitabilityScore: marine.waveHeight > 1.2 ? 92 : 82,
            weatherMatchReason:
                'Arabian Sea water temp (${marine.seaTemperature.round()}°C) is comfortable for water wading.',
            bestTimeToVisit: '06:30 AM – 09:00 AM',
            highlights: ['Surf Schools Available', 'Wide Sandy Expanse', 'Fishing Village Culture'],
            emoji: '🏄',
            mapsQuery: 'Versova Beach Mumbai',
          ),
          const PlaceSuggestionModel(
            id: 'mumbai_beach_2',
            name: 'Juhu Beach Sunset Shoreline',
            category: 'Vibrant Coastal Promenade',
            description:
                'Iconic flat tidal beach popular for morning yoga, sand runs, evening sunset walks, and sea breezes.',
            addressOrArea: 'Juhu Tara Road, Mumbai',
            suitabilityScore: 88,
            weatherMatchReason:
                'Tide status allows expansive walking sand flats during low tide hours.',
            bestTimeToVisit: '05:00 PM – 07:00 PM',
            highlights: ['Expansive Sand Flats', 'Famous Street Food Stalls', 'Sunset Photography'],
            emoji: '🏖️',
            mapsQuery: 'Juhu Beach Mumbai',
          ),
        ];

      case Personas.family:
        return [
          const PlaceSuggestionModel(
            id: 'mumbai_family_1',
            name: 'Veermata Jijabai Bhosale Botanical Udyan & Zoo',
            category: 'Historic Zoo & Penguin Habitat',
            description:
                '53-acre heritage garden in Byculla with Humboldt penguins, walk-through bird aviary, and hundreds of centuries-old trees.',
            addressOrArea: 'Byculla East, Mumbai',
            suitabilityScore: 95,
            weatherMatchReason:
                'Indoor Penguin building is fully climate-controlled if afternoon temperature rises.',
            bestTimeToVisit: '09:30 AM – 01:00 PM',
            highlights: ['Humboldt Penguin Exhibit', 'Walk-through Bird Aviary', 'Toy Train', 'Heritage Tree Walks'],
            emoji: '🐧',
            mapsQuery: 'Byculla Zoo Mumbai',
          ),
          const PlaceSuggestionModel(
            id: 'mumbai_family_2',
            name: 'Kamala Nehru Park & Old Woman\'s Shoe',
            category: 'Fairy Tale Children\'s Hilltop Park',
            description:
                'Delightful renovated kids park featuring the famous giant boot play structure, tree houses, and practical viewing gallery.',
            addressOrArea: 'Malabar Hill, Mumbai',
            suitabilityScore: 91,
            weatherMatchReason:
                'Cool hilltop marine air keeps children comfortable outdoors.',
            bestTimeToVisit: '04:00 PM – 06:30 PM',
            highlights: ['Giant Boot Slide Structure', 'Queen\'s Necklace Viewing Deck', 'Soft Play Lawns'],
            emoji: '👢',
            mapsQuery: 'Kamala Nehru Park Mumbai',
          ),
        ];

      case Personas.agriculture:
        return [
          const PlaceSuggestionModel(
            id: 'mumbai_agri_1',
            name: 'Maharashtra Nature Park (Mahim Nature Park)',
            category: 'Urban Reforestation & Nature Sanctuary',
            description:
                'Miracle urban forest built on a former landfill. Features rich vermiculture pits, medicinal plant nurseries, and mangrove eco-zones.',
            addressOrArea: 'Bandra-Sion Link Road, Dharavi, Mumbai',
            suitabilityScore: 95,
            weatherMatchReason:
                'High organic soil richness and demonstration nurseries for organic gardening.',
            bestTimeToVisit: '08:30 AM – 12:00 PM',
            highlights: ['Medicinal Plant Conservatory', 'Vermicomposting Unit', 'Butterfly Aviary', 'Botanical Experts'],
            emoji: '🌱',
            mapsQuery: 'Maharashtra Nature Park Mumbai',
          ),
        ];

      case Personas.commuter:
        return [
          const PlaceSuggestionModel(
            id: 'mumbai_commute_1',
            name: 'CSMT & Churchgate Subsurface Transit Skywalk',
            category: 'Weather-Proof High-Speed Transit Corridor',
            description:
                'Underground and covered ped-skywalk systems protecting daily rail passengers from heat, monsoon showers, and surface gridlocks.',
            addressOrArea: 'Fort & South Mumbai Transit Corridor',
            suitabilityScore: 96,
            weatherMatchReason:
                'Total protection from rain bursts and high summer humidity.',
            bestTimeToVisit: 'All Commute Hours',
            highlights: ['Direct Rail-to-Office Connectivity', 'Covered Walkways', 'Frequent Fast Trains'],
            emoji: '🚆',
            mapsQuery: 'CSMT Station Mumbai',
          ),
        ];

      case Personas.traveler:
        return [
          PlaceSuggestionModel(
            id: 'mumbai_travel_1',
            name: 'Gateway of India & Colaba Heritage Quarter',
            category: 'Historic Waterfront & Colonial Architecture',
            description:
                '1924 basalt ceremonial arch overlooking Mumbai harbor, facing the legendary Taj Mahal Palace hotel.',
            addressOrArea: 'Apollo Bunder, Colaba, Mumbai',
            suitabilityScore: 96,
            weatherMatchReason:
                'Sea visibility (${(weather.visibility / 1000).toStringAsFixed(1)} km) offers striking harbor boat photography.',
            bestTimeToVisit: '04:30 PM – 07:00 PM',
            highlights: ['Harbor Boat Cruises', 'Heritage Architecture', 'Artisan Shopping in Colaba Causeway'],
            emoji: '🏛️',
            mapsQuery: 'Gateway of India Mumbai',
          ),
        ];

      case Personas.event:
        return [
          PlaceSuggestionModel(
            id: 'mumbai_event_1',
            name: 'Mahalaxmi Racecourse Members Enclosure Lawns',
            category: 'Grand Heritage Open-Air Lawn',
            description:
                '225 acres of manicured heritage lawns framed by the South Mumbai skyline, ideal for high-profile weddings and galas.',
            addressOrArea: 'Mahalaxmi, Mumbai',
            suitabilityScore: weather.precipitationProbability < 30 ? 98 : 75,
            weatherMatchReason:
                'Current low rain probability makes this grand lawn the premier open-air venue today.',
            bestTimeToVisit: '06:00 PM – 11:30 PM',
            highlights: ['Historic Grandstand Backdrop', 'Acres of Open Greenery', 'Ample VIP Parking'],
            emoji: '🎉',
            mapsQuery: 'Mahalaxmi Racecourse Mumbai',
          ),
        ];

      default:
        return _generateDynamicCitySuggestions(
          persona: persona,
          cityName: 'Mumbai',
          weather: weather,
          airQuality: airQuality,
          marine: marine,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Predefined Iconic Spots for Delhi
  // ---------------------------------------------------------------------------
  List<PlaceSuggestionModel> _getDelhiSuggestions(
    String persona,
    WeatherModel weather,
    AirQualityModel airQuality,
    MarineModel marine,
  ) {
    switch (persona) {
      case Personas.fitness:
        return [
          PlaceSuggestionModel(
            id: 'delhi_fit_1',
            name: 'Lodhi Garden Jogging Tracks',
            category: 'Heritage Running Trail Amid Tombs',
            description:
                '90 acres of manicured historical gardens with 2.2km cushioned clay walking and jogging tracks among 15th-century monuments.',
            addressOrArea: 'Lodhi Road, New Delhi',
            suitabilityScore: WeatherHelpers.runScore(weather),
            weatherMatchReason:
                'Mature banyan and neem trees buffer direct morning heat and city noise.',
            bestTimeToVisit: '06:00 AM – 08:30 AM',
            highlights: ['2.2km Clay Track', '15th Century Monuments', 'High Tree Canopy', 'Security Guards'],
            emoji: '🏃',
            mapsQuery: 'Lodhi Garden New Delhi',
          ),
          const PlaceSuggestionModel(
            id: 'delhi_fit_2',
            name: 'Nehru Park Chanakyapuri Track',
            category: 'Diplomatic Enclave Running Loop',
            description:
                '80-acre undulating park with soft grass mounds, rubberized jogging paths, and outdoor workout areas.',
            addressOrArea: 'Chanakyapuri, New Delhi',
            suitabilityScore: 92,
            weatherMatchReason:
                'Cleanest diplomatic zone air with well-maintained synthetic running lanes.',
            bestTimeToVisit: '06:30 AM – 08:30 AM',
            highlights: ['Synthetic Track', 'Gentle Incline Mounds', 'Open Gym', 'Diplomatic Security'],
            emoji: '🌳',
            mapsQuery: 'Nehru Park Chanakyapuri New Delhi',
          ),
        ];

      case Personas.health:
        return [
          const PlaceSuggestionModel(
            id: 'delhi_health_1',
            name: 'Sunder Nursery Ecological Heritage Park',
            category: 'UNESCO World Heritage Arboretum & Oxygen Haven',
            description:
                '90-acre heritage park with over 300 tree species, clean micro-habitats, flowing marble fountains, and the lowest particulate pollution in central Delhi.',
            addressOrArea: 'Nizamuddin, New Delhi',
            suitabilityScore: 97,
            weatherMatchReason:
                'Over 20,000 trees produce clean micro-filtered air and reduce ambient temperature by 3°C.',
            bestTimeToVisit: '06:30 AM – 09:30 AM',
            highlights: ['Biodiversity Arboretum', 'Bird Sanctuary', 'Organic Weekend Market', 'Pristine Lake Beds'],
            emoji: '🌲',
            mapsQuery: 'Sunder Nursery New Delhi',
          ),
          const PlaceSuggestionModel(
            id: 'delhi_health_2',
            name: 'Aravalli Biodiversity Park',
            category: 'Indigenous Forest Eco-Zone',
            description:
                'Restored 692-acre native forest reserve with indigenous flora acting as a giant natural air filter on the Delhi-Gurugram border.',
            addressOrArea: 'Vasant Vihar / Mehrauli, New Delhi',
            suitabilityScore: 94,
            weatherMatchReason:
                'Dense native scrub and trees filter dust storms and vehicular exhaust.',
            bestTimeToVisit: '06:00 AM – 09:00 AM',
            highlights: ['Natural Bird Trails', 'Wild Flora Trails', 'Zero Traffic Sound'],
            emoji: '🌿',
            mapsQuery: 'Aravalli Biodiversity Park New Delhi',
          ),
        ];

      case Personas.family:
        return [
          const PlaceSuggestionModel(
            id: 'delhi_fam_1',
            name: 'National Science Centre & Sensory Park',
            category: 'Interactive Edutainment & Science Grounds',
            description:
                'Eight levels of hands-on interactive galleries, dinosaur robotic gallery, and spacious outdoor physics park for kids.',
            addressOrArea: 'Near Pragati Maidan, Bhairon Road, New Delhi',
            suitabilityScore: 95,
            weatherMatchReason:
                'Air-conditioned indoor pavilions provide refuge from harsh sun or dust.',
            bestTimeToVisit: '10:30 AM – 03:30 PM',
            highlights: ['Dinosaur Gallery', 'Fun Science Lab', '3D Theater', 'Spacious Cafeteria'],
            emoji: '🔬',
            mapsQuery: 'National Science Centre New Delhi',
          ),
        ];

      case Personas.traveler:
        return [
          PlaceSuggestionModel(
            id: 'delhi_travel_1',
            name: 'Humayun\'s Tomb & Sunder Nursery Complex',
            category: 'Mughal Architectural Masterpiece',
            description:
                '16th-century garden tomb of Emperor Humayun, the architectural inspiration for the Taj Mahal, set within lush Persian charbagh gardens.',
            addressOrArea: 'Mathura Road, Nizamuddin East, New Delhi',
            suitabilityScore: 96,
            weatherMatchReason:
                'Clear morning visibility (${(weather.visibility / 1000).toStringAsFixed(1)} km) highlights intricate red sandstone and white marble.',
            bestTimeToVisit: '07:00 AM – 10:00 AM or 04:30 PM for Sunset',
            highlights: ['Persian Charbagh Water Channels', 'UNESCO World Heritage', 'Photographer’s Paradise'],
            emoji: '🕌',
            mapsQuery: 'Humayuns Tomb New Delhi',
          ),
        ];

      default:
        return _generateDynamicCitySuggestions(
          persona: persona,
          cityName: 'New Delhi',
          weather: weather,
          airQuality: airQuality,
          marine: marine,
        );
    }
  }

  // Fallbacks for other major cities
  List<PlaceSuggestionModel> _getBengaluruSuggestions(String p, WeatherModel w, AirQualityModel a, MarineModel m) =>
      _generateDynamicCitySuggestions(persona: p, cityName: 'Bengaluru', weather: w, airQuality: a, marine: m);

  List<PlaceSuggestionModel> _getLondonSuggestions(String p, WeatherModel w, AirQualityModel a, MarineModel m) =>
      _generateDynamicCitySuggestions(persona: p, cityName: 'London', weather: w, airQuality: a, marine: m);

  List<PlaceSuggestionModel> _getNewYorkSuggestions(String p, WeatherModel w, AirQualityModel a, MarineModel m) =>
      _generateDynamicCitySuggestions(persona: p, cityName: 'New York', weather: w, airQuality: a, marine: m);

  List<PlaceSuggestionModel> _getDubaiSuggestions(String p, WeatherModel w, AirQualityModel a, MarineModel m) =>
      _generateDynamicCitySuggestions(persona: p, cityName: 'Dubai', weather: w, airQuality: a, marine: m);
}
