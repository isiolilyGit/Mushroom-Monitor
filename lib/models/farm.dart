class SensorSource {
  final int channelId;
  final String readApiKey;

  /// IMPORTANT: this is now STRING, not int
  /// Example: "field1", "field2"
  final String fieldKey;

  final String label;

  /// optional but needed for your dashboard later
  double? minIdeal;
  double? maxIdeal;

  SensorSource({
    required this.channelId,
    required this.readApiKey,
    required this.fieldKey,
    required this.label,
    this.minIdeal,
    this.maxIdeal,
  });

  Map<String, dynamic> toJson() => {
        'channelId': channelId,
        'readApiKey': readApiKey,
        'fieldKey': fieldKey,
        'label': label,
        'minIdeal': minIdeal,
        'maxIdeal': maxIdeal,
      };

  factory SensorSource.fromJson(Map<String, dynamic> json) => SensorSource(
        channelId: json['channelId'],
        readApiKey: json['readApiKey'],
        fieldKey: json['fieldKey'],
        label: json['label'],
        minIdeal: (json['minIdeal'] as num?)?.toDouble(),
        maxIdeal: (json['maxIdeal'] as num?)?.toDouble(),
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