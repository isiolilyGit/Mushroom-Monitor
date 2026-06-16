class SensorSource {
  final int channelId;
  final String readApiKey;
  final int fieldNumber;   // 1–8 for ThingSpeak
  final String label;      // e.g., "Temperature"

  SensorSource({
    required this.channelId,
    required this.readApiKey,
    required this.fieldNumber,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'channelId': channelId,
        'readApiKey': readApiKey,
        'fieldNumber': fieldNumber,
        'label': label,
      };

  factory SensorSource.fromJson(Map<String, dynamic> json) => SensorSource(
        channelId: json['channelId'],
        readApiKey: json['readApiKey'],
        fieldNumber: json['fieldNumber'],
        label: json['label'],
      );
}

class Farm {
  String name;
  List<SensorSource> sensors;

  Farm({required this.name, required this.sensors});

  Map<String, dynamic> toJson() => {
        'name': name,
        'sensors': sensors.map((s) => s.toJson()).toList(),
      };

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
        name: json['name'],
        sensors: (json['sensors'] as List)
            .map((s) => SensorSource.fromJson(s))
            .toList(),
      );
}