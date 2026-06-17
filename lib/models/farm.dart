class SensorSource {
  final int channelId;
  final String readApiKey;
  String? writeApiKey;
  final String unit;

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
    this.writeApiKey,
    required this.unit,
    required this.fieldKey,
    required this.label,
    this.minIdeal,
    this.maxIdeal,
  });

  Map<String, dynamic> toJson() => {
        'channelId': channelId,
        'readApiKey': readApiKey,
        'writeApiKey': writeApiKey,
        'fieldKey': fieldKey,
        'label': label,
        'unit' : unit,
        'minIdeal': minIdeal,
        'maxIdeal': maxIdeal,
      };

  factory SensorSource.fromJson(Map<String, dynamic> json) => SensorSource(
        channelId: json['channelId'],
        readApiKey: json['readApiKey'],
        writeApiKey: json['writeApiKey'],
        fieldKey: json['fieldKey'],
        label: json['label'],
        unit: json['unit'] ?? '',
        minIdeal: (json['minIdeal'] as num?)?.toDouble(),
        maxIdeal: (json['maxIdeal'] as num?)?.toDouble(),
      );
}

class Farm {
  final String id;
  final String name;
  final DateTime startDate;
  final List<SensorSource> sensors;

  Farm({
    required this.id,
    required this.name,
    required this.startDate,
    required this.sensors,
  });

  int get ageDays {
  return DateTime.now()
      .difference(startDate)
      .inDays;
}


  String get growthStage {

  if (ageDays <= 3) {
    return "Colonization Stage";
  }

  if (ageDays <= 10) {
    return "Pinning Stage";
  }

  if (ageDays <= 20) {
    return "Fruiting Stage";
  }

  return "Harvest Stage";

}
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'sensors': sensors.map((s) => s.toJson()).toList(),
      };

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
        id: json['id'],
        name: json['name'],
        startDate: json['startDate'] == null ? DateTime.now() : DateTime.parse((json['startDate'])??DateTime.now()),
        sensors: (json['sensors'] as List)
            .map((s) => SensorSource.fromJson(s))
            .toList(),
      );
}