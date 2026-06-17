import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// ── Data model ───────────────────────────────────────────

class StageParameters {
  double minTemp, maxTemp;
  double minHumidity, maxHumidity;
  double co2Threshold;
  double luxTarget;
  int fanPWM;

  StageParameters({
    required this.minTemp,
    required this.maxTemp,
    required this.minHumidity,
    required this.maxHumidity,
    required this.co2Threshold,
    required this.luxTarget,
    required this.fanPWM,
  });

  Map<String, dynamic> toMap() => {
    'min_temp': minTemp,
    'max_temp': maxTemp,
    'min_humidity': minHumidity,
    'max_humidity': maxHumidity,
    'co2_threshold': co2Threshold,
    'lux_target': luxTarget,
    'fan_pwm': fanPWM,
  };

  factory StageParameters.fromMap(Map<String, dynamic> map) => StageParameters(
    minTemp: (map['min_temp'] ?? 0).toDouble(),
    maxTemp: (map['max_temp'] ?? 0).toDouble(),
    minHumidity: (map['min_humidity'] ?? 0).toDouble(),
    maxHumidity: (map['max_humidity'] ?? 0).toDouble(),
    co2Threshold: (map['co2_threshold'] ?? 0).toDouble(),
    luxTarget: (map['lux_target'] ?? 0).toDouble(),
    fanPWM: (map['fan_pwm'] ?? 0).toInt(),
  );

  factory StageParameters.defaultSpawnRun() => StageParameters(
    minTemp: 22,
    maxTemp: 28,
    minHumidity: 80,
    maxHumidity: 95,
    co2Threshold: 5000,
    luxTarget: 50,
    fanPWM: 120,
  );

  factory StageParameters.defaultPrimordia() => StageParameters(
    minTemp: 16,
    maxTemp: 22,
    minHumidity: 85,
    maxHumidity: 95,
    co2Threshold: 1000,
    luxTarget: 300,
    fanPWM: 180,
  );

  factory StageParameters.defaultFruiting() => StageParameters(
    minTemp: 18,
    maxTemp: 24,
    minHumidity: 80,
    maxHumidity: 90,
    co2Threshold: 800,
    luxTarget: 700,
    fanPWM: 200,
  );
}

// ── Screen ───────────────────────────────────────────────

class GrowthStageScreen extends StatefulWidget {
  const GrowthStageScreen({super.key});

  @override
  State<GrowthStageScreen> createState() => _GrowthStageScreenState();
}

class _GrowthStageScreenState extends State<GrowthStageScreen> {
  static const _bg = Color(0xFF0F1F0F);
  static const _cardBg = Color(0xFF1A2E1A);
  static const _border = Color(0xFF2E7D32);
  static const _accent = Color(0xFF69F0AE);
  static const _textPrimary = Color(0xFFE8F5E9);
  static const _textSecondary = Color(0xFF81C784);

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isLoading = true;

  // Realtime Database reference
  final _dbRef = FirebaseDatabase.instance.ref('growth_stages/parameters');

  final List<Map<String, dynamic>> _stages = [
    {
      'key': 'spawn_run',
      'label': 'Spawn run',
      'badge': 'Stage 1',
      'color': const Color(0xFF69F0AE),
      'badgeBg': const Color(0xFF1B3A2A),
    },
    {
      'key': 'primordia',
      'label': 'Primordia',
      'badge': 'Stage 2',
      'color': const Color(0xFF40C4FF),
      'badgeBg': const Color(0xFF1A2A3A),
    },
    {
      'key': 'fruiting',
      'label': 'Fruiting',
      'badge': 'Stage 3',
      'color': const Color(0xFFFFD54F),
      'badgeBg': const Color(0xFF3A2E1A),
    },
  ];

  late Map<String, Map<String, TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadFromDatabase();
  }

  @override
  void dispose() {
    for (final s in _controllers.values) {
      for (final c in s.values) c.dispose();
    }
    super.dispose();
  }

  // ── Controller init ──────────────────────────────────

  void _initControllers() {
    final defaults = {
      'spawn_run': StageParameters.defaultSpawnRun(),
      'primordia': StageParameters.defaultPrimordia(),
      'fruiting': StageParameters.defaultFruiting(),
    };
    _controllers = {
      for (final stage in _stages)
        stage['key'] as String: _makeControllers(defaults[stage['key']]!),
    };
  }

  Map<String, TextEditingController> _makeControllers(StageParameters p) => {
    'minTemp': TextEditingController(text: p.minTemp.toString()),
    'maxTemp': TextEditingController(text: p.maxTemp.toString()),
    'minHumidity': TextEditingController(text: p.minHumidity.toString()),
    'maxHumidity': TextEditingController(text: p.maxHumidity.toString()),
    'co2Threshold': TextEditingController(text: p.co2Threshold.toString()),
    'luxTarget': TextEditingController(text: p.luxTarget.toString()),
    'fanPWM': TextEditingController(text: p.fanPWM.toString()),
  };

  // ── Realtime Database ────────────────────────────────

  Future<void> _loadFromDatabase() async {
    try {
      final snapshot = await _dbRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (final stage in _stages) {
          final key = stage['key'] as String;
          if (data.containsKey(key)) {
            final p = StageParameters.fromMap(
              Map<String, dynamic>.from(data[key] as Map),
            );
            final cs = _controllers[key]!;
            cs['minTemp']!.text = p.minTemp.toString();
            cs['maxTemp']!.text = p.maxTemp.toString();
            cs['minHumidity']!.text = p.minHumidity.toString();
            cs['maxHumidity']!.text = p.maxHumidity.toString();
            cs['co2Threshold']!.text = p.co2Threshold.toString();
            cs['luxTarget']!.text = p.luxTarget.toString();
            cs['fanPWM']!.text = p.fanPWM.toString();
          }
        }
      }
    } catch (e) {
      _showSnack('Could not load saved parameters', isError: true);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveToDatabase() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{};
      for (final stage in _stages) {
        final key = stage['key'] as String;
        final c = _controllers[key]!;
        payload[key] = StageParameters(
          minTemp: double.parse(c['minTemp']!.text),
          maxTemp: double.parse(c['maxTemp']!.text),
          minHumidity: double.parse(c['minHumidity']!.text),
          maxHumidity: double.parse(c['maxHumidity']!.text),
          co2Threshold: double.parse(c['co2Threshold']!.text),
          luxTarget: double.parse(c['luxTarget']!.text),
          fanPWM: int.parse(c['fanPWM']!.text),
        ).toMap();
      }

      await _dbRef.set(payload);

      _showSnack('Parameters saved successfully');
    } catch (e) {
      _showSnack('Save failed — check your connection', isError: true);
    }

    setState(() => _isSaving = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFB71C1C) : _border,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Validation ───────────────────────────────────────

  String? _validateNumber(String? v, double min, double max) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = double.tryParse(v);
    if (n == null) return 'Invalid number';
    if (n < min || n > max) return '${min.toInt()}–${max.toInt()}';
    return null;
  }

  // ── Build ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF69F0AE)),
              )
            : Form(
                key: _formKey,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🌾 Growth Stage',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Set parameters for each mushroom growth stage',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            index == _stages.length - 1 ? 0 : 16,
                          ),
                          child: _buildStageCard(_stages[index]),
                        ),
                        childCount: _stages.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                        child: _buildSaveButton(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Stage card ───────────────────────────────────────

  Widget _buildStageCard(Map<String, dynamic> stage) {
    final key = stage['key'] as String;
    final label = stage['label'] as String;
    final badge = stage['badge'] as String;
    final color = stage['color'] as Color;
    final badgeBg = stage['badgeBg'] as Color;
    final c = _controllers[key]!;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card body ────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temperature
                _sectionLabel('Temperature'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Min temp',
                        controller: c['minTemp']!,
                        unit: '°C',
                        hint: 'e.g. 22',
                        validator: (v) => _validateNumber(v, 0, 50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Max temp',
                        controller: c['maxTemp']!,
                        unit: '°C',
                        hint: 'e.g. 28',
                        validator: (v) => _validateNumber(v, 0, 50),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Humidity
                _sectionLabel('Humidity'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Min humidity',
                        controller: c['minHumidity']!,
                        unit: '%',
                        hint: 'e.g. 80',
                        validator: (v) => _validateNumber(v, 0, 100),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Max humidity',
                        controller: c['maxHumidity']!,
                        unit: '%',
                        hint: 'e.g. 95',
                        validator: (v) => _validateNumber(v, 0, 100),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // CO2 & Fan — row 1
                _sectionLabel('CO₂, Light & Fan'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'CO₂ threshold',
                        controller: c['co2Threshold']!,
                        unit: 'ppm',
                        hint: 'e.g. 1000',
                        validator: (v) => _validateNumber(v, 0, 10000),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildField(
                        label: 'Fan PWM',
                        controller: c['fanPWM']!,
                        unit: '0–255',
                        hint: 'e.g. 150',
                        isInt: true,
                        validator: (v) => _validateNumber(v, 0, 255),
                      ),
                    ),
                  ],
                ),

                // Light target — row 2
                const SizedBox(height: 12),
                _buildField(
                  label: 'Light target',
                  controller: c['luxTarget']!,
                  unit: 'lux',
                  hint: 'e.g. 500',
                  validator: (v) => _validateNumber(v, 0, 100000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable widgets ─────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: _textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
    ),
  );

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String unit,
    required String hint,
    String? Function(String?)? validator,
    bool isInt = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          validator: validator,
          style: const TextStyle(color: _textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _textSecondary.withOpacity(0.5),
              fontSize: 12,
            ),
            suffixText: unit,
            suffixStyle: const TextStyle(color: _textSecondary, fontSize: 10),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFF0F1F0F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF5350)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFEF5350),
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(color: Color(0xFFEF9A9A), fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveToDatabase,
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0F1F0F),
                ),
              )
            : const Icon(
                Icons.save_rounded,
                size: 20,
                color: Color(0xFF0F1F0F),
              ),
        label: Text(
          _isSaving ? 'Saving...' : 'Save parameters',
          style: const TextStyle(
            color: Color(0xFF0F1F0F),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          disabledBackgroundColor: _accent.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
