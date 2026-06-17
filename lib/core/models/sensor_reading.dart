class SensorReading {
  final DateTime createdAt;
  final double? temperature;
  final double? humidity;
  final double? co2;
  final double? light;

  SensorReading({
    required this.createdAt,
    this.temperature,
    this.humidity,
    this.co2,
    this.light,
  });

  factory SensorReading.fromThingSpeak(Map<String, dynamic> json) {
    return SensorReading(
      createdAt: DateTime.parse(json['created_at']),
      temperature: double.tryParse(json['field1'] ?? ''),
      humidity: double.tryParse(json['field2'] ?? ''),
      co2: double.tryParse(json['field3'] ?? ''),
      light: double.tryParse(json['field4'] ?? ''),
    );
  }
}
