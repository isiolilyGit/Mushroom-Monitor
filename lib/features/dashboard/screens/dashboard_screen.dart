import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/live_sensor_provider.dart';
import '../screens/chart_screen.dart';
import 'package:mushroom_monitor/core/services/thingspeak_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncControlled = ref.watch(liveSensorProvider);
    final asyncUncontrolled = ref.watch(liveUncontrolledProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page header ─────────────────────────────────────
              const Text(
                '🌱 Grow Room',
                style: TextStyle(
                  color: Color(0xFFE8F5E9),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Live sensor readings',
                style: TextStyle(color: Color(0xFF81C784), fontSize: 13),
              ),

              const SizedBox(height: 28),

              // ── Controlled experiment ────────────────────────────
              _ExperimentPanel(
                title: 'Controlled',
                emoji: '🧪',
                asyncReading: asyncControlled,
                channel: MushroomChannel.controlled,
              ),

              const SizedBox(height: 28),

              // ── Divider ──────────────────────────────────────────
              Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFF2E7D32),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Uncontrolled experiment ──────────────────────────
              _ExperimentPanel(
                title: 'Uncontrolled',
                emoji: '🌿',
                asyncReading: asyncUncontrolled,
                channel: MushroomChannel.uncontrolled,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Experiment panel ──────────────────────────────────────────────────────────
class _ExperimentPanel extends StatelessWidget {
  final String title;
  final String emoji;
  final AsyncValue asyncReading;
  final MushroomChannel channel;

  const _ExperimentPanel({
    required this.title,
    required this.emoji,
    required this.asyncReading,
    required this.channel,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _navigateToChart(
    BuildContext context,
    String parameterName,
    String unit,
    Color accentColor,
    IconData icon,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartScreen(
          channel: channel,
          parameterName: parameterName,
          unit: unit,
          accentColor: accentColor,
          icon: icon,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Panel header ─────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$emoji $title',
              style: const TextStyle(
                color: Color(0xFFE8F5E9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            _StatusBadge(asyncReading: asyncReading),
          ],
        ),

        const SizedBox(height: 6),

        // ── Timestamp ─────────────────────────────────────────
        asyncReading.whenOrNull(
              data: (reading) => Text(
                'Updated ${_formatTime(reading.createdAt.toLocal())}',
                style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11),
              ),
            ) ??
            const SizedBox.shrink(),

        const SizedBox(height: 16),

        // ── Content ───────────────────────────────────────────
        asyncReading.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (reading) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SensorTile(
                      label: 'Temperature',
                      value: reading.temperature,
                      unit: '°C',
                      icon: Icons.thermostat_rounded,
                      accentColor: const Color(0xFFFF7043),
                      iconBg: const Color(0xFF3E1A10),
                      onTap: () => _navigateToChart(
                        context,
                        'Temperature',
                        '°C',
                        const Color(0xFFFF7043),
                        Icons.thermostat_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SensorTile(
                      label: 'Humidity',
                      value: reading.humidity,
                      unit: '%',
                      icon: Icons.water_drop_rounded,
                      accentColor: const Color(0xFF29B6F6),
                      iconBg: const Color(0xFF0D2A38),
                      onTap: () => _navigateToChart(
                        context,
                        'Humidity',
                        '%',
                        const Color(0xFF29B6F6),
                        Icons.water_drop_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SensorTile(
                      label: 'CO₂',
                      value: reading.co2,
                      unit: 'ppm',
                      icon: Icons.air_rounded,
                      accentColor: const Color(0xFF66BB6A),
                      iconBg: const Color(0xFF1A3A1A),
                      onTap: () => _navigateToChart(
                        context,
                        'CO₂',
                        'ppm',
                        const Color(0xFF66BB6A),
                        Icons.air_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SensorTile(
                      label: 'Light',
                      value: reading.light,
                      unit: 'lux',
                      icon: Icons.wb_sunny_rounded,
                      accentColor: const Color(0xFFFFCA28),
                      iconBg: const Color(0xFF3A2E00),
                      onTap: () => _navigateToChart(
                        context,
                        'Light',
                        'lux',
                        const Color(0xFFFFCA28),
                        Icons.wb_sunny_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Health bar ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2E1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E7D32), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: Color(0xFF66BB6A),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'All systems nominal',
                        style: TextStyle(
                          color: Color(0xFF81C784),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Healthy',
                        style: TextStyle(
                          color: Color(0xFFE8F5E9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final AsyncValue asyncReading;
  const _StatusBadge({required this.asyncReading});

  @override
  Widget build(BuildContext context) {
    final isLive = asyncReading is AsyncData;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLive
            ? const Color(0xFF1B5E20).withValues(alpha: 0.6)
            : Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive ? const Color(0xFF4CAF50) : Colors.redAccent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLive ? const Color(0xFF69F0AE) : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isLive ? 'Live' : 'Offline',
            style: TextStyle(
              color: isLive ? const Color(0xFF69F0AE) : Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sensor tile ───────────────────────────────────────────────────────────────
class _SensorTile extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final Color iconBg;
  final VoidCallback? onTap;

  const _SensorTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    required this.iconBg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF162016),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF81C784),
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value != null ? value!.toStringAsFixed(1) : '--',
                      style: const TextStyle(
                        color: Color(0xFFE8F5E9),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF81C784), fontSize: 13),
            ),
            if (onTap != null) const SizedBox(height: 4),
            if (onTap != null)
              Text(
                'Tap for chart',
                style: TextStyle(
                  color: const Color(0xFF81C784).withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
