import 'package:flutter/material.dart';
import '../services/real_obd_service.dart';

class OBDDashboardScreen extends StatefulWidget {
  const OBDDashboardScreen({super.key});

  @override
  State<OBDDashboardScreen> createState() => _OBDDashboardScreenState();        
}

class _OBDDashboardScreenState extends State<OBDDashboardScreen> {
  bool _isConnected = false;
  bool _isConnecting = false;
  Map<String, String> _sensorData = {};
  List<String> _troubleCodes = [];
  bool _isLoading = true;
  String _connectionStatus = "Alege modul de conexiune";
  List<String> _foundDevices = [];
  String _connectionType = "Necunoscut";
  String _scanLog = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _connectToDemo() async {
    setState(() {
      _isLoading = true;
      _isConnecting = true;
      _connectionStatus = "ÌøÅ Pornire mod DEMO...";
      _scanLog = "";
    });

    try {
      bool connected = await RealOBDService.enableDemoMode();
      
      setState(() {
        _isConnected = connected;
        _isConnecting = false;
        _connectionType = RealOBDService.getConnectionType();
        
        if (connected) {
          _connectionStatus = "‚úÖ Mod DEMO activat!";
          _startLiveData();
        } else {
          _connectionStatus = "‚ùå Eroare mod DEMO";
        }
      });

    } catch (e) {
      setState(() {
        _isConnected = false;
        _isConnecting = false;
        _isLoading = false;
        _connectionStatus = "‚ùå Eroare: $e";
      });
    }
  }

  Future<void> _connectToRealOBD() async {
    setState(() {
      _isLoading = true;
      _isConnecting = true;
      _connectionStatus = "Ì¥ç Se cautƒÉ dispozitive OBD2...";
      _scanLog = "√éncepere scanare...\\n";
    });

    try {
      bool connected = await RealOBDService.connectToRealDevice();
      _foundDevices = RealOBDService.getFoundDevices();
      _scanLog = RealOBDService.getScanLog();
      
      setState(() {
        _isConnected = connected;
        _isConnecting = false;
        _connectionType = RealOBDService.getConnectionType();
        
        if (connected) {
          _connectionStatus = "‚úÖ Conectat la OBD2 real!";
          _startLiveData();
        } else if (_foundDevices.isNotEmpty) {
          _connectionStatus = "‚ùå Conexiune e»ôuatƒÉ";
        } else {
          _connectionStatus = "‚ùå Nu s-au gƒÉsit dispozitive OBD2";
        }
      });

      if (!connected) {
        setState(() {
          _isLoading = false;
        });
        _showConnectionResult();
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isConnecting = false;
        _isLoading = false;
        _connectionStatus = "‚ùå Eroare: $e";
      });
      _showConnectionResult();
    }
  }

  void _showConnectionResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_isConnected ? "Conectat! Ìæâ" : "Conexiune e»ôuatƒÉ ‚ùå"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_foundDevices.isNotEmpty) ...[
                  Text("Dispozitive OBD gƒÉsite:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._foundDevices.map((device) => Text("‚Ä¢ $device")),
                  SizedBox(height: 10),
                ],
                
                Text("Detalii scanare:", style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _scanLog,
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
                SizedBox(height: 10),
                
                if (!_isConnected) ...[
                  Text("Sfaturi de depanare:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  Text("‚Ä¢ AsigurƒÉ-te cƒÉ ELM327 este pornit (LED albastru)"),
                  Text("‚Ä¢ VerificƒÉ Bluetooth pe telefon"),
                  Text("‚Ä¢ Porne»ôte ma»ôina (contact ON)"),
                  Text("‚Ä¢ √éncearcƒÉ sƒÉ resetezi dispozitivul OBD"),
                  Text("‚Ä¢ VerificƒÉ dacƒÉ nu este deja pereche cu alt telefon"),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _connectToRealOBD();
              },
              child: Text("Re√ÆncearcƒÉ"),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _startLiveData() async {
    while (_isConnected && RealOBDService.isConnected) {
      await _updateSensorData();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _updateSensorData() async {
    if (!_isConnected) return;

    try {
      final tempResponse = await RealOBDService.sendCommand("0105");
      final rpmResponse = await RealOBDService.sendCommand("010C");
      final speedResponse = await RealOBDService.sendCommand("010D");
      final codesResponse = await RealOBDService.sendCommand("03");

      setState(() {
        _sensorData = {
          'Engine Temp': _parseTemperature(tempResponse),
          'RPM': _parseRPM(rpmResponse),
          'Speed': _parseSpeed(speedResponse),
          'Voltage': _parseVoltage(),
        };

        _troubleCodes = _parseTroubleCodes(codesResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _sensorData = {
          'Engine Temp': 'Eroare',
          'RPM': 'Eroare', 
          'Speed': 'Eroare',
          'Voltage': 'Eroare',
        };
        _isLoading = false;
      });
    }
  }

  String _parseTemperature(String response) {
    if (response.contains("41 05")) {
      try {
        final parts = response.split(' ');
        int temp = int.parse(parts[2], radix: 16);
        String indicator = RealOBDService.isDemoMode ? "Ì∑™" : "Ì∫ó";
        return '${temp - 40}¬∞C $indicator';
      } catch (e) {
        return 'Eroare';
      }
    }
    return '--';
  }

  String _parseRPM(String response) {
    if (response.contains("41 0C")) {
      try {
        final parts = response.split(' ');
        int a = int.parse(parts[2], radix: 16);
        int b = int.parse(parts[3], radix: 16);
        int rpm = ((a * 256) + b) ~/ 4;
        String indicator = RealOBDService.isDemoMode ? "Ì∑™" : "Ì∫ó";
        return '$rpm RPM $indicator';
      } catch (e) {
        return 'Eroare';
      }
    }
    return '--';
  }

  String _parseSpeed(String response) {
    if (response.contains("41 0D")) {
      try {
        final parts = response.split(' ');
        int speed = int.parse(parts[2], radix: 16);
        String indicator = RealOBDService.isDemoMode ? "Ì∑™" : "Ì∫ó";
        return '$speed km/h $indicator';
      } catch (e) {
        return 'Eroare';
      }
    }
    return '--';
  }

  String _parseVoltage() {
    if (RealOBDService.isDemoMode) {
      double baseVoltage = 13.8;
      double variation = (DateTime.now().millisecond % 100) / 100.0;
      return '${(baseVoltage + variation).toStringAsFixed(1)}V Ì∑™';
    } else {
      return '14.2V Ì∫ó';
    }
  }

  List<String> _parseTroubleCodes(String response) {
    if (response.contains("43 00") || response.contains("NO DATA")) {
      return ['‚úÖ Niciun cod de eroare'];
    }
    return ['Ì¥ç Se analizeazƒÉ codurile...'];
  }

  Future<void> _disconnect() async {
    await RealOBDService.disconnect();
    setState(() {
      _isConnected = false;
      _isLoading = false;
      _connectionStatus = "Deconectat";
      _connectionType = "DECONECTAT";
      _sensorData = {};
      _troubleCodes = [];
      _scanLog = "";
    });
  }

  Widget _buildDataCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD2 Dashboard'),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _disconnect,
        ),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _updateSensorData,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.shade50 : 
                       _isConnecting ? Colors.orange.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isConnected ? Colors.green : 
                         _isConnecting ? Colors.orange : Colors.blue,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.check_circle : 
                    _isConnecting ? Icons.bluetooth_searching : Icons.bluetooth,
                    color: _isConnected ? Colors.green : 
                           _isConnecting ? Colors.orange : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _connectionType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isConnected ? Colors.green : 
                                   _isConnecting ? Colors.orange : Colors.blue,    
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _connectionStatus,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isConnecting) 
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Butoane de conexiune (c√¢nd nu suntem conecta»õi)
            if (!_isConnected && !_isConnecting) ...[
              Text(
                'Alege modul de conexiune:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              
              // Buton DEMO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _connectToDemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: Icon(Icons.science, color: Colors.white),
                  label: Text(
                    'MOD DEMO Ì∑™',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Buton OBD REAL
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _connectToRealOBD,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: Icon(Icons.directions_car, color: Colors.white),
                  label: Text(
                    'OBD REAL Ì∫ó',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              Text(
                'Ì≤° Mod Demo: Date simulate pentru testare\nÌ∫ó OBD Real: Conectare la dispozitivul tƒÉu ELM327',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],

            // Live Data Grid (c√¢nd suntem conecta»õi)
            if (_isLoading) ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Se √ÆncarcƒÉ datele OBD2...'),
                    ],
                  ),
                ),
              ),
            ] else if (_isConnected) ...[
              const Text(
                'Ì≥ä Date √Æn Timp Real',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildDataCard('TEMPERATURƒÇ', _sensorData['Engine Temp'] ?? '--', Colors.orange),
                    _buildDataCard('RPM', _sensorData['RPM'] ?? '--', Colors.blue),
                    _buildDataCard('VITEZƒÇ', _sensorData['Speed'] ?? '--', Colors.green),
                    _buildDataCard('TENSIUNE', _sensorData['Voltage'] ?? '--', Colors.purple),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Trouble Codes
              if (_troubleCodes.isNotEmpty) ...[
                const Text(
                  '‚ö†Ô∏è Coduri de Eroare',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _troubleCodes[0].contains('Niciun') ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _troubleCodes[0].contains('Niciun') ? Colors.green.shade300 : Colors.orange.shade300,
                    ),
                  ),
                  child: Column(
                    children: _troubleCodes.map((code) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        code,
                        style: TextStyle(
                          fontSize: 12,
                          color: _troubleCodes[0].contains('Niciun') ? Colors.green : Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Disconnect Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _disconnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'DECONECTEAZƒÇ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isConnected = false;
    super.dispose();
  }
}
