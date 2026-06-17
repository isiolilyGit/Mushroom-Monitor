import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushroom_monitor/features/dashboard/screens/dashboard_screen.dart';
import 'package:mushroom_monitor/features/dashboard/screens/manual_control_screen.dart';
import 'package:mushroom_monitor/features/dashboard/screens/growth_stage_screen.dart';
import 'package:mushroom_monitor/features/dashboard/screens/settings_screen.dart';

// Tracks which tab is currently selected
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const List<Widget> _pages = [
    DashboardScreen(),
    ManualControlScreen(),
    GrowthStageScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1F0F),

      // Swap pages without rebuilding the whole tree
      body: IndexedStack(index: currentIndex, children: _pages),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF2E7D32), width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) =>
              ref.read(bottomNavIndexProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF162016),
          selectedItemColor: const Color(0xFF69F0AE),
          unselectedItemColor: const Color(0xFF4A6741),
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              label: 'Manual',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_rounded),
              label: 'Growth',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
