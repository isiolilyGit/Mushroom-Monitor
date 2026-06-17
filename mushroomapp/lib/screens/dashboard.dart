import 'package:flutter/material.dart';

import 'package:mushroomapp/models/sensor_models.dart';
import 'package:mushroomapp/services/env_controller.dart';
//import 'package:mushroomapp/screens/sensor_charts.dart';

// Mushroom Growth Dashboard Screen
// It includes - Start/Stop controls, live data stream, and status indicators
// It listens to the EnvironmentController's stream and updates the UI in real-time
class DashboardScreen extends StatefulWidget {
  final EnvironmentController controller;

  const DashboardScreen({
    super.key,
    required this.controller,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _alertEmail;
  bool isMonitoring = false;

  Future<String?> _showEmailDialog() async {
  final emailController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Alert Email'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter email address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                emailController.text.trim(),
              );
            },
            child: const Text('Start Monitoring'),
          ),
        ],
      );
    },
  );
}

  Color _statusColor(String status) {
    switch (status) {
      case SensorStatus.normal:
        return Colors.green;
      case SensorStatus.warning:
        return Colors.orange;
      case SensorStatus.critical:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case SensorStatus.normal:
        return Icons.check_circle;
      case SensorStatus.warning:
        return Icons.warning;
      case SensorStatus.critical:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

 Future<void> _startMonitoring() async {
  final email = await _showEmailDialog();

  if (email == null || email.isEmpty) {
    return;
  }

  if (!email.contains('@')) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a valid email address'),
      ),
    );

    return;
  }

  _alertEmail = email;

  widget.controller.setAlertRecipients([
    email,
  ]);

  widget.controller.startMonitoring(
    interval: const Duration(seconds: 10),
  );

  setState(() {
    isMonitoring = true;
  });
}

  void _stopMonitoring() {
    widget.controller.stopMonitoring();

    setState(() {
      isMonitoring = false;
    });
  }

  @override
  void dispose() {
    widget.controller.stopMonitoring();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mushroom Growth Dashboard'),
        centerTitle: true,
      ),

      body: Column(
        children: [

          
          // CONTROL PANEL (START / STOP)
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton(
                  onPressed: isMonitoring ? null : _startMonitoring,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("START"),
                ),

                ElevatedButton(
                  onPressed: isMonitoring ? _stopMonitoring : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("STOP"),
                ),
              ],
            ),
          ),

          Text(
            isMonitoring ? "Monitoring ACTIVE" : "Monitoring STOPPED",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMonitoring ? Colors.green : Colors.red,
            ),
            
          ),

          if (_alertEmail != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Alert Email: $_alertEmail',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 10),


          // LIVE DATA STREAM
        
          Expanded(
            child: StreamBuilder<ClassificationResult>(
              stream: widget.controller.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text("Press START to begin monitoring"),
                  );
                }

                final result = snapshot.data!;
                final color = _statusColor(result.status);

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //  STATUS CARD - Shows overall status with color coding and message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _statusIcon(result.status),
                              color: color,
                              size: 40,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.status,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  result.message,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      //  SENSOR CARDS 
                      
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          children: [
                            _buildSensorCard(
                              title: "Temperature",
                              value: "${result.temperature} °C",
                              icon: Icons.thermostat,
                              color: Colors.blue,
                            ),
                            _buildSensorCard(
                              title: "Humidity",
                              value: "${result.humidity} %",
                              icon: Icons.water_drop,
                              color: Colors.cyan,
                            ),
                            _buildSensorCard(
                              title: "CO₂",
                              value: "${result.co2} ppm",
                              icon: Icons.cloud,
                              color: Colors.purple,
                            ),
                            _buildSensorCard(
                              title: "Stage",
                              value: "Spawn Run",
                              icon: Icons.eco,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}