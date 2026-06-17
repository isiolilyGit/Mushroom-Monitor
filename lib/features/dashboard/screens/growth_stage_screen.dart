import 'package:flutter/material.dart';

class GrowthStageScreen extends StatelessWidget {
  const GrowthStageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '🌾 Growth Stage',
                style: TextStyle(
                  color: Color(0xFFE8F5E9),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your mushroom growth cycle',
                style: TextStyle(color: Color(0xFF81C784), fontSize: 13),
              ),

              const SizedBox(height: 40),

              // Placeholder content
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2E1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF2E7D32),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF69F0AE),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Color(0xFFE8F5E9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inoculation, colonisation, pinning\nand fruiting stages will be tracked here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF81C784),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
