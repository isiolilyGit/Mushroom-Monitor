import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/farm_provider.dart';
import 'screens/farm_list_screen.dart';
import 'theme.dart';

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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // ✅ START HERE (not dashboard directly)
        home: Consumer<FarmProvider>(
          builder: (context, provider, child) {
            if(!provider.isLoaded) {
              return const Scaffold(body: Center(child: CircularProgressIndicator(),),);}
            return const FarmListScreen();
          }),
      ),
    );
  }
}