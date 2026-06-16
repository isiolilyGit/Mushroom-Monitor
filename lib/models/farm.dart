class SensorSource {
  final String id;
  final int channelId;
  final String readApiKey;
  final int fieldNumber;
  final String label;

  // 👇 NEW: ideal range for alerts
  final double minIdeal;
  final double maxIdeal;

  SensorSource({
    required this.id,
    required this.channelId,
    required this.readApiKey,
    required this.fieldNumber,
    required this.label,
    required this.minIdeal,
    required this.maxIdeal,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'channelId': channelId,
        'readApiKey': readApiKey,
        'fieldNumber': fieldNumber,
        'label': label,
        'minIdeal': minIdeal,
        'maxIdeal': maxIdeal,
      };

  factory SensorSource.fromJson(Map<String, dynamic> json) => SensorSource(
        id: json['id'],
        channelId: json['channelId'],
        readApiKey: json['readApiKey'],
        fieldNumber: json['fieldNumber'],
        label: json['label'],
        minIdeal: (json['minIdeal'] ?? 0).toDouble(),
        maxIdeal: (json['maxIdeal'] ?? 100).toDouble(),
      );
}

class Farm {
  final String id;
  final String name;
  final List<SensorSource> sensors;

  Farm({
    required this.id,
    required this.name,
    required this.sensors,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sensors': sensors.map((s) => s.toJson()).toList(),
      };

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
        id: json['id'],
        name: json['name'],
        sensors: (json['sensors'] as List)
            .map((s) => SensorSource.fromJson(s))
            .toList(),
      );
}