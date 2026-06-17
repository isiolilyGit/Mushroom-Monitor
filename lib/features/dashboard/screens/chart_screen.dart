import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mushroom_monitor/core/services/thingspeak_service.dart';
import '../providers/live_sensor_provider.dart';

class ChartScreen extends ConsumerStatefulWidget {
  final MushroomChannel channel;
  final String parameterName;
  final String unit;
  final Color accentColor;
  final IconData icon;

  const ChartScreen({
    super.key,
    required this.channel,
    required this.parameterName,
    required this.unit,
    required this.accentColor,
    required this.icon,
  });

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  int _selectedTab = 0;

  int _historyCount = 50;
  final List<int> _historyOptions = [10, 25, 50, 100, 500];

  List<FlSpot> _liveSpots = [];
  double? _currentValue;
  DateTime? _lastUpdate;

  List<FlSpot> _historySpots = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  late final VoidCallback _refreshListener;

  @override
  void initState() {
    super.initState();
    _refreshListener = _updateLiveData;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLiveData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateLiveData() {
    final provider = widget.channel == MushroomChannel.controlled
        ? liveSensorProvider
        : liveUncontrolledProvider;

    final asyncValue = ref.read(provider);
    if (asyncValue is AsyncData) {
      final reading = asyncValue.value;
      final value = _getParameterValue(reading);
      setState(() {
        _currentValue = value;
        _lastUpdate = DateTime.now();
        _liveSpots = _generateLiveSpots(value);
      });
    }
  }

  double? _getParameterValue(dynamic reading) {
    switch (widget.parameterName) {
      case 'Temperature':
        return reading.temperature;
      case 'Humidity':
        return reading.humidity;
      case 'CO₂':
        return reading.co2;
      case 'Light':
        return reading.light;
      default:
        return null;
    }
  }

  List<FlSpot> _generateLiveSpots(double? value) {
    final spots = <FlSpot>[];
    if (value == null) return spots;
    for (int i = 0; i < 20; i++) {
      final variation = (i % 3 - 1) * (value * 0.02);
      spots.add(FlSpot(i.toDouble(), value + variation));
    }
    return spots;
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final service = ThingSpeakService(channel: widget.channel);
      final readings = await service.fetchHistory(count: _historyCount);

      final spots = <FlSpot>[];
      for (int i = 0; i < readings.length; i++) {
        final value = _getParameterValue(readings[i]);
        if (value != null) {
          spots.add(FlSpot(i.toDouble(), value));
        }
      }

      setState(() {
        _historySpots = spots;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _historyError = 'Failed to load history: $e';
        _isLoadingHistory = false;
      });
    }
  }

  // ─── Y-axis helpers ────────────────────────────────────────────────────────

  /// Nice rounded min — keeps data snug to the bottom like ThingSpeak.
  double _calculateMinY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    final rawMin = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final rawMax = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = rawMax - rawMin;

    // Flat line: give ±5 % of the value itself as breathing room
    if (range == 0) return (rawMin * 0.95).floorToDouble();

    final padding = range * 0.10;
    return _niceFloor(rawMin - padding);
  }

  double _calculateMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    final rawMin = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final rawMax = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = rawMax - rawMin;

    if (range == 0) return (rawMax * 1.05).ceilToDouble();

    final padding = range * 0.10;
    return _niceCeil(rawMax + padding);
  }

  /// Rounds DOWN to the nearest "nice" step.
  double _niceFloor(double v) {
    final step = _niceStep(v);
    return (v / step).floorToDouble() * step;
  }

  /// Rounds UP to the nearest "nice" step.
  double _niceCeil(double v) {
    final step = _niceStep(v);
    return (v / step).ceilToDouble() * step;
  }

  /// Picks a rounding granularity based on the magnitude of the value.
  double _niceStep(double v) {
    final abs = v.abs();
    if (abs < 1) return 0.1;
    if (abs < 10) return 1;
    if (abs < 100) return 5;
    if (abs < 1000) return 10;
    return 50;
  }

  /// Horizontal grid interval — 5–8 lines in the visible range.
  double _calculateAutoInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final range = _calculateMaxY(spots) - _calculateMinY(spots);
    if (range == 0) return 1;

    // Target ~6 grid lines
    final rawInterval = range / 6;

    // Round to a "nice" value
    const niceIntervals = <double>[
      0.1,
      0.2,
      0.5,
      1,
      2,
      5,
      10,
      20,
      25,
      50,
      100,
      200,
      500,
    ];
    return niceIntervals.firstWhere(
      (i) => i >= rawInterval,
      orElse: () => rawInterval,
    );
  }

  // ─── X-axis helper ─────────────────────────────────────────────────────────

  /// Never show more than ~8 labels on the X axis.
  int _calculateXInterval(int dataPoints) {
    if (dataPoints <= 8) return 1;
    if (dataPoints <= 20) return 2;
    if (dataPoints <= 40) return 5;
    if (dataPoints <= 100) return 10;
    if (dataPoints <= 250) return 25;
    return 50;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFFE8F5E9),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(widget.icon, color: widget.accentColor, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${widget.parameterName} Chart',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE8F5E9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedTab == 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButton<int>(
                value: _historyCount,
                dropdownColor: const Color(0xFF1A2E1A),
                style: const TextStyle(color: Color(0xFFE8F5E9), fontSize: 13),
                underline: const SizedBox(),
                items: _historyOptions
                    .map(
                      (c) => DropdownMenuItem(value: c, child: Text('$c pts')),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _historyCount = value);
                    _fetchHistory();
                  }
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTabSelector(),
          if (_selectedTab == 0) _buildCurrentValueDisplay(),
          Expanded(
            child: _selectedTab == 0 ? _buildLiveChart() : _buildHistoryChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF2E7D32), width: 1),
      ),
      child: Row(
        children: [
          _buildTabButton('🔴 Live', 0),
          _buildTabButton('📊 Historical', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            if (index == 1 && _historySpots.isEmpty) _fetchHistory();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF81C784),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentValueDisplay() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: widget.accentColor, size: 26),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current ${widget.parameterName}',
                    style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    _currentValue != null
                        ? '${_currentValue!.toStringAsFixed(1)} ${widget.unit}'
                        : '-- ${widget.unit}',
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Live chart ────────────────────────────────────────────────────────────

  Widget _buildLiveChart() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF162016),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Updates',
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _lastUpdate != null
                      ? 'Updated: ${DateFormat('HH:mm:ss').format(_lastUpdate!)}'
                      : 'Waiting for data...',
                  style: const TextStyle(
                    color: Color(0xFF81C784),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _liveSpots.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  )
                : LineChart(_liveChartData()),
          ),
        ],
      ),
    );
  }

  LineChartData _liveChartData() {
    final minY = _calculateMinY(_liveSpots);
    final maxY = _calculateMaxY(_liveSpots);
    final interval = _calculateAutoInterval(_liveSpots);

    return LineChartData(
      clipData: const FlClipData.all(), // prevents overflow outside axes
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (_) => FlLine(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // Wide enough for values like "1024.0" without clipping
            reservedSize: 48,
            interval: interval,
            getTitlesWidget: (value, meta) {
              // Skip the very top/bottom labels that fl_chart auto-adds
              // (they can overlap the border)
              if (value == meta.min || value == meta.max) {
                return const SizedBox.shrink();
              }
              return Text(
                _formatAxisValue(value),
                style: const TextStyle(color: Color(0xFF81C784), fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 5, // show every 5th point label
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx % 5 != 0 && idx != 19) return const SizedBox.shrink();
              final minutes = (19 - idx) * 2;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  minutes > 0 ? '-${minutes}m' : 'Now',
                  style: const TextStyle(color: Color(0xFF81C784), fontSize: 9),
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: 19,
      minY: minY,
      maxY: maxY,
      lineBarsData: [_buildLineBar(_liveSpots, dotRadius: 3.5)],
    );
  }

  // ─── History chart ─────────────────────────────────────────────────────────

  Widget _buildHistoryChart() {
    if (_isLoadingHistory) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4CAF50)),
            SizedBox(height: 14),
            Text(
              'Loading historical data...',
              style: TextStyle(color: Color(0xFF81C784)),
            ),
          ],
        ),
      );
    }

    if (_historyError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 44),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _historyError!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _fetchHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_historySpots.isEmpty) {
      return const Center(
        child: Text(
          'No historical data available',
          style: TextStyle(color: Color(0xFF81C784)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF162016),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last ${_historySpots.length} readings',
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_historySpots.length} pts',
                  style: const TextStyle(
                    color: Color(0xFF81C784),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: LineChart(_historyChartData())),
        ],
      ),
    );
  }

  LineChartData _historyChartData() {
    final count = _historySpots.length;
    final minY = _calculateMinY(_historySpots);
    final maxY = _calculateMaxY(_historySpots);
    final yInterval = _calculateAutoInterval(_historySpots);
    final xInterval = _calculateXInterval(count);

    return LineChartData(
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: yInterval,
        getDrawingHorizontalLine: (_) => FlLine(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              if (value == meta.min || value == meta.max) {
                return const SizedBox.shrink();
              }
              return Text(
                _formatAxisValue(value),
                style: const TextStyle(color: Color(0xFF81C784), fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: xInterval.toDouble(),
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              // Only render at exact multiples + the last point
              if (idx % xInterval != 0 && idx != count - 1) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '#${idx + 1}',
                  style: const TextStyle(color: Color(0xFF81C784), fontSize: 9),
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: (count - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        _buildLineBar(
          _historySpots,
          dotRadius: count > 50 ? 0 : 2.5,
          showDots: count <= 100,
        ),
      ],
    );
  }

  // ─── Shared line bar builder ───────────────────────────────────────────────

  LineChartBarData _buildLineBar(
    List<FlSpot> spots, {
    double dotRadius = 3,
    bool showDots = true,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.25,
      color: widget.accentColor,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: showDots,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: dotRadius,
          color: widget.accentColor,
          strokeWidth: 1.5,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: widget.accentColor.withValues(alpha: 0.08),
      ),
    );
  }

  // ─── Axis value formatter ──────────────────────────────────────────────────

  /// Shows integers without decimals, small floats with 1 dp.
  String _formatAxisValue(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
