import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/farm_provider.dart';
import 'screens/farm_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FarmProvider()..loadFarms(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mushroom Monitor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),

        // ✅ START HERE (not dashboard directly)
        home: const FarmListScreen(),
      ),
    );
  }
}