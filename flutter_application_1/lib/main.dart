import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/obd_service.dart';

void main() {
  // Activează modul simulare pentru demo
  OBDService.enableSimulationMode();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Diagnostic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
