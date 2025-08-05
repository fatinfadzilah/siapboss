class LocationSuggestion {
  final String name;
  final double lat;
  final double lon;

  LocationSuggestion({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['name'],
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
    );
  }
}
