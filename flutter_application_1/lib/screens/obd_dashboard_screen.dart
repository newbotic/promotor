import 'package:flutter/material.dart';
import '../services/obd_service.dart';

class OBDDashboardScreen extends StatefulWidget {
  const OBDDashboardScreen({super.key});

  @override
  State<OBDDashboardScreen> createState() => _OBDDashboardScreenState();
}

class _OBDDashboardScreenState extends State<OBDDashboardScreen> {
  bool isConnected = false;
  bool isScanning = false;
  Map<String, String> sensorData = {};
  List<String> troubleCodes = [];

  @override
  void initState() {
    super.initState();
    _connectToOBD();
  }

  Future<void> _connectToOBD() async {
    setState(() {
      isScanning = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    final connected = await OBDService.connectToOBD();
    
    setState(() {
      isConnected = connected;
      isScanning = false;
    });

    if (connected) {
      _startSensorMonitoring();
    }
  }

  Future<void> _startSensorMonitoring() async {
    while (isConnected) {
      await _updateSensorData();
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _updateSensorData() async {
    if (!isConnected) return;

    final temp = await OBDService.getEngineTemp();
    final rpm = await OBDService.getEngineRPM();
    final codes = await OBDService.getTroubleCodes();

    setState(() {
      sensorData = {
        'Engine Temp': temp.split(' - ')[0],
        'RPM': rpm.split(' ')[0],
        'Speed': '65',
        'Fuel Consumption': '8.2',
      };
      troubleCodes = codes;
    });
  }

  Future<void> _clearTroubleCodes() async {
    setState(() {
      troubleCodes = [];
    });
    await Future.delayed(const Duration(seconds: 2));
  }

  Widget _buildDashboardCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
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
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: 8,
              color: color.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(IconData icon, String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD2 Car Scanner'),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth, color: Colors.white),
            onPressed: _connectToOBD,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Bar
            _buildStatusBar(),
            
            const SizedBox(height: 12),
            
            // Live Dashboard - DIMENSIUNI FIXE
            SizedBox(
              height: 120, // Înălțime fixă
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '��� Dashboard Live',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 0.8,
                      children: [
                        _buildDashboardCard('TEMP', sensorData['Engine Temp'] ?? '--', '°C', Colors.orange),
                        _buildDashboardCard('RPM', sensorData['RPM'] ?? '--', 'RPM', Colors.blue),
                        _buildDashboardCard('VITEZĂ', sensorData['Speed'] ?? '--', 'KM/H', Colors.green),
                        _buildDashboardCard('CONSUM', sensorData['Fuel Consumption'] ?? '--', 'L/100KM', Colors.purple),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Features Title
            const Text(
              '��� Funcții OBD2',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Features Grid - DIMENSIUNI FIXE
            SizedBox(
              height: 150, // Înălțime fixă
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.9,
                children: [
                  _buildFeatureButton(Icons.show_chart, 'Senzori', () {
                    _showSnackbar(context, 'Afișează toți senzorii');
                  }, Colors.blue),
                  
                  _buildFeatureButton(Icons.warning, 'Erori', () {
                    _showTroubleCodesDialog(context);
                  }, Colors.orange),
                  
                  _buildFeatureButton(Icons.build, 'Teste', () {
                    _showSnackbar(context, 'Testează actuatori');
                  }, Colors.green),
                  
                  _buildFeatureButton(Icons.assignment, 'Rapoarte', () {
                    _showSnackbar(context, 'Generează rapoarte');
                  }, Colors.purple),
                  
                  _buildFeatureButton(Icons.tune, 'Live Data', () {
                    _showSnackbar(context, 'Date live detaliate');
                  }, Colors.red),
                  
                  _buildFeatureButton(Icons.auto_graph, 'Grafice', () {
                    _showSnackbar(context, 'Afișează grafice');
                  }, Colors.teal),
                  
                  _buildFeatureButton(Icons.cleaning_services, 'Șterge', _clearTroubleCodes, Colors.amber),
                  
                  _buildFeatureButton(Icons.settings, 'Setări', () {
                    _showSnackbar(context, 'Setări OBD2');
                  }, Colors.grey),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Scan Button
            _buildScanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
            color: isConnected ? Colors.green : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'CONECTAT - OBD2' : 'SCANARE...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
                if (isConnected) ...[
                  const SizedBox(height: 2),
                  Text(
                    'VW Golf 1.6 TDI • 2018',
                    style: TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          if (troubleCodes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${troubleCodes.length} erori',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isConnected ? _updateSensorData : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
        label: const Text(
          'SCANARE AUTOMATĂ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showTroubleCodesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Coduri de Eroare'),
        content: troubleCodes.isEmpty
            ? const Text('✅ Niciun cod de eroare detectat!')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: troubleCodes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              troubleCodes[index],
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Închide'),
          ),
          if (troubleCodes.isNotEmpty)
            TextButton(
              onPressed: () {
                _clearTroubleCodes();
                Navigator.pop(context);
              },
              child: const Text('Șterge Erori'),
            ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message - În dezvoltare!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    isConnected = false;
    super.dispose();
  }
}
