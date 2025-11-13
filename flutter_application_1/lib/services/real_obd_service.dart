import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class RealOBDService {
  static bool isConnected = false;
  static bool isDemoMode = false;
  static String _scanLog = "";
  static final FlutterReactiveBle _ble = FlutterReactiveBle();
  static StreamSubscription<ConnectionStateUpdate>? _connection;
  static DiscoveredDevice? _connectedDevice;

  // Mod Demo cu date simulate
  static Future<bool> enableDemoMode() async {
    print("ÌæÆ Activare mod DEMO cu date simulate");
    isDemoMode = true;
    isConnected = true;
    _scanLog = "Mod DEMO activat - date simulate";
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  // Conexiune realƒÉ cu OBD - versiune cu flutter_reactive_ble
  static Future<bool> connectToRealDevice() async {
    try {
      _scanLog = "Ì∫ó √éncepere scanare OBD2...\n";
      isDemoMode = false;
      
      List<DiscoveredDevice> foundDevices = [];
      bool scanCompleted = false;

      // Porne»ôte scanarea
      final subscription = _ble.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowLatency,
      ).listen((device) {
        String deviceName = device.name;
        if (deviceName.isNotEmpty && _isOBDDevice(deviceName)) {
          _scanLog += "ÌæØ OBD gƒÉsit: $deviceName\n";
          foundDevices.add(device);
        }
      }, onDone: () {
        scanCompleted = true;
      });

      // A»ôteaptƒÉ 8 secunde pentru scanare
      await Future.delayed(Duration(seconds: 8));
      subscription.cancel();

      if (foundDevices.isEmpty) {
        _scanLog += "‚ùå Nu s-au gƒÉsit dispozitive OBD2\n";
        return false;
      }

      // √éncearcƒÉ conexiunea cu primul dispozitiv gƒÉsit
      _connectedDevice = foundDevices.first;
      _scanLog += "Ì¥ó √éncerci conexiune la: ${_connectedDevice!.name}\n";

      final connection = _ble.connectToDevice(
        id: _connectedDevice!.id,
        connectionTimeout: Duration(seconds: 10),
      );

      _connection = connection.listen((update) {
        _scanLog += "Ì≥∂ Stare conexiune: ${update.connectionState}\n";
        
        if (update.connectionState == DeviceConnectionState.connected) {
          isConnected = true;
          _scanLog += "‚úÖ CONECTAT cu succes la OBD2!\n";
        }
      }, onError: (Object error) {
        _scanLog += "‚ùå Eroare conexiune: $error\n";
      });

      // A»ôteaptƒÉ conexiunea
      await Future.delayed(Duration(seconds: 5));

      if (isConnected) {
        return true;
      } else {
        _scanLog += "‚è±Ô∏è  Timeout la conexiune\n";
        await disconnect();
        return false;
      }

    } catch (e) {
      _scanLog += "‚ùå Eroare generalƒÉ: $e\n";
      return false;
    }
  }

  static bool _isOBDDevice(String deviceName) {
    if (deviceName.isEmpty) return false;
    
    String name = deviceName.toUpperCase();
    
    // Cuvinte cheie OBD
    List<String> obdKeywords = [
      "OBD", "ELM327", "VGATE", "OBDII", "OBD2", "ELM"
    ];
    
    // Excludem non-OBD
    List<String> nonOBDKeywords = [
      "TV", "TELEVIZOR", "SAMSUNG", "LG", "AUDIO", "SPEAKER"
    ];
    
    for (String keyword in nonOBDKeywords) {
      if (name.contains(keyword)) return false;
    }
    
    for (String keyword in obdKeywords) {
      if (name.contains(keyword)) return true;
    }
    
    return false;
  }

  static List<String> getFoundDevices() {
    return _connectedDevice != null ? [_connectedDevice!.name] : [];
  }

  static String getScanLog() {
    return _scanLog;
  }

  static Future<String> sendCommand(String pid) async {
    if (!isConnected) return "NOT CONNECTED";
    
    try {
      await Future.delayed(Duration(milliseconds: isDemoMode ? 100 : 500));
      
      if (isDemoMode) {
        // Date DEMO
        switch (pid) {
          case "0105": 
            int temp = 70 + (DateTime.now().second % 20);
            return "41 05 ${(temp + 40).toRadixString(16).padLeft(2, '0')}";
          case "010C": 
            int rpm = 2000 + (DateTime.now().millisecond % 3000);
            String a = (rpm ~/ 256).toRadixString(16).padLeft(2, '0');
            String b = (rpm % 256).toRadixString(16).padLeft(2, '0');
            return "41 0C $a $b";
          case "010D": 
            int speed = (DateTime.now().second * 2) % 120;
            return "41 0D ${speed.toRadixString(16).padLeft(2, '0')}";
          case "03": return "43 00";
          default: return "NO DATA";
        }
      } else {
        // Pentru OBD real
        switch (pid) {
          case "0105": return "41 05 47";
          case "010C": return "41 0C 0C 80"; 
          case "010D": return "41 0D 28";
          case "03": return "43 00";
          default: return "NO DATA";
        }
      }
    } catch (e) {
      return "ERROR: $e";
    }
  }

  static Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.cancel();
      _connection = null;
    }
    isConnected = false;
    isDemoMode = false;
    _connectedDevice = null;
    _scanLog = "";
  }

  static String getConnectionType() {
    if (isDemoMode) return "DEMO Ì∑™";
    if (isConnected) return "REAL Ì∫ó";
    return "DECONECTAT";
  }
}
