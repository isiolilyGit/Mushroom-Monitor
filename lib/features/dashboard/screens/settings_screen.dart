import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushroom_monitor/features/dashboard/providers/auth_provider.dart';
import 'package:mushroom_monitor/features/dashboard/screens/login_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '⚙️ Settings',
                style: TextStyle(
                  color: Color(0xFFE8F5E9),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your account & preferences',
                style: TextStyle(color: Color(0xFF81C784), fontSize: 13),
              ),

              const SizedBox(height: 32),

              // Account section
              _SectionLabel(label: 'Account'),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Logged in as',
                trailing: Text(
                  user?.email ?? '—',
                  style: const TextStyle(
                    color: Color(0xFF81C784),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 28),

              // Preferences section
              _SectionLabel(label: 'Preferences'),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                trailing: const Text(
                  'Coming soon',
                  style: TextStyle(color: Color(0xFF4A6741), fontSize: 13),
                ),
              ),

              const SizedBox(height: 8),

              _SettingsTile(
                icon: Icons.refresh_rounded,
                label: 'Refresh interval',
                trailing: const Text(
                  'Coming soon',
                  style: TextStyle(color: Color(0xFF4A6741), fontSize: 13),
                ),
              ),

              const SizedBox(height: 40),

              // Sign out button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authService.signOut();
                    // AuthWrapper will automatically navigate to LoginScreen
                    // No manual navigation needed
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF5350),
                    size: 20,
                  ),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(
                      color: Color(0xFFEF5350),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF5350), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF4A6741),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF162016),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF81C784), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE8F5E9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: trailing),
        ],
      ),
    );
  }
}
