import 'package:flutter/foundation.dart';

class OBDService {
  static bool _isConnected = false;
  static bool _simulationMode = true;
  
  // Simulează conexiunea la OBD2
  static Future<bool> connectToOBD() async {
    await Future.delayed(const Duration(seconds: 2));
    _isConnected = true;
    return _isConnected;
  }
  
  // Simulează citirea temperaturii motorului
  static Future<String> getEngineTemp() async {
    if (!_isConnected && !_simulationMode) {
      return 'Nu ești conectat la OBD2';
    }
    
    // Valori simulate realiste
    final baseTemp = 20;
    final variation = DateTime.now().second % 40;
    final temp = baseTemp + variation;
    
    if (temp < 40) return '\${temp}°C - Motor rece';
    if (temp < 80) return '\${temp}°C - Motor încălzindu-se';
    if (temp < 100) return '\${temp}°C - Temperatură normală';
    return '\${temp}°C - ATENȚIE: Supraîncălzire!';
  }
  
  // Simulează citirea codurilor de eroare
  static Future<List<String>> getTroubleCodes() async {
    if (!_isConnected && !_simulationMode) {
      return ['Conectează-te la OBD2 pentru a citi codurile'];
    }
    
    // Coduri simulate pentru demo - bazate pe problema selectată
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      'P0128 - Răcire termostatului sub temperatură',
      'P0300 - Misfire cilindri multipli',
      'P0420 - Eficiență scăzută catalizator'
    ];
  }
  
  // Simulează citirea RPM
  static Future<String> getEngineRPM() async {
    if (!_isConnected && !_simulationMode) {
      return '0 RPM';
    }
    
    final baseRPM = 800;
    final variation = (DateTime.now().millisecond % 2000);
    final rpm = baseRPM + variation;
    
    if (rpm < 1000) return '\$rpm RPM - Ralanti';
    if (rpm < 3000) return '\$rpm RPM - Viteză normală';
    return '\$rpm RPM - RPM ridicat';
  }
  
  // Simulează date pentru probleme specifice
  static Future<Map<String, String>> getProblemSpecificData(String problemId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final data = {
      '1': '���️ Temperatură: 45°C (creștere lentă)\\n��� RPM: 850\\n⚠️ Termostat probabil blocat deschis',
      '2': '���️ Temperatură: 87°C\\n��� RPM: 2100\\n⚠️ Sondă Lambda: valoare scăzută 0.1V',
      '3': '���️ Temperatură: 92°C\\n��� RPM: 750\\n⚠️ EGR: debit 0% - supapă blocată',
      '4': '���️ Temperatură: 85°C\\n��� RPM: 3200\\n⚠️ Misfire detectat cilindrul 3',
      '5': '��️ Temperatură: 88°C\\n��� RPM: 1800\\n⚠️ MAF: 2.1 g/s - valoare instabilă',
    };
    
    return {'diagnostic': data[problemId] ?? 'Date indisponibile'};
  }
  
  static bool get isConnected => _isConnected;
  static bool get simulationMode => _simulationMode;
  
  static Future<void> disconnect() async {
    _isConnected = false;
  }
  
  static void enableSimulationMode() {
    _simulationMode = true;
    _isConnected = true;
  }
}
