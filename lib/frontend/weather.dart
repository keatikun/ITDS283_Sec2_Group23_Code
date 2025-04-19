class Weather {
  final String day;
  final double temperature;
  final String condition;

  Weather({
    required this.day,
    required this.temperature,
    required this.condition,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String day) {
    return Weather(
      day: day,
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
    );
  }
}