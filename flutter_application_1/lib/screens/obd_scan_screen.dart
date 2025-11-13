import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/real_obd_service.dart';
import 'obd_dashboard_screen.dart';

class OBDScanScreen extends StatefulWidget {
  const OBDScanScreen({super.key});

  @override
  State<OBDScanScreen> createState() => _OBDScanScreenState();
}

class _OBDScanScreenState extends State<OBDScanScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  String _status = 'Pregătit pentru scanare';
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _checkBluetooth();
  }

  Future<void> _checkBluetooth() async {
    bool isOn = await FlutterBluePlus.isOn;
    if (!isOn) {
      setState(() {
        _status = 'Pornește Bluetooth-ul pentru a scana';
      });
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _devices = [];
      _status = 'Scanare dispozitive OBD2...';
    });

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (_isOBDDevice(result.device)) {
          if (!_devices.contains(result.device)) {
            setState(() {
              _devices.add(result.device);
            });
          }
        }
      }
    });

    // Start scan for 15 seconds
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() {
      _isScanning = false;
      _status = _devices.isEmpty 
          ? 'Nu s-au găsit dispozitive OBD2' 
          : '${_devices.length} dispozitive găsite';
    });
  }

  bool _isOBDDevice(BluetoothDevice device) {
    String name = device.platformName.toLowerCase();
    // Filtrează doar dispozitivele OBD2
    return name.contains('obd') || 
           name.contains('elm327') || 
           name.contains('蓝牙') ||
           name.contains('vgate') ||
           name.contains('car') ||
           device.remoteId.toString().contains('OBD');
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _status = 'Se conectează la ${device.platformName}...';
      _connectedDevice = device;
    });

    try {
      bool connected = await RealOBDService.connectToDevice(device);
      
      if (connected) {
        // Testează conexiunea cu o comandă simplă
        String response = await RealOBDService.sendCommand("ATZ");
        
        if (response.contains("ELM327") || !response.contains("ERR")) {
          setState(() {
            _status = 'Conectat cu succes!';
          });
          
          // Navighează către dashboard după 1 secundă
          await Future.delayed(const Duration(seconds: 1));
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OBDDashboardScreen(),
            ),
          );
        } else {
          setState(() {
            _status = 'Dispozitivul nu a răspuns corect';
          });
          await RealOBDService.disconnect();
        }
      } else {
        setState(() {
          _status = 'Eroare la conectare';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Eroare: $e';
      });
    }
    
    setState(() {
      _connectedDevice = null;
    });
  }

  Widget _buildDeviceCard(BluetoothDevice device) {
    bool isConnecting = _connectedDevice == device;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          isConnecting ? Icons.bluetooth_searching : Icons.bluetooth,
          color: isConnecting ? Colors.orange : Colors.blue,
        ),
        title: Text(
          device.platformName.isNotEmpty 
              ? device.platformName 
              : 'Dispozitiv OBD2',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${device.remoteId.toString()}'),
            if (isConnecting) ...[
              const SizedBox(height: 4),
              const Text(
                'Se conectează...',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ],
        ),
        trailing: isConnecting
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _connectToDevice(device),
                child: const Text('CONECTEAZĂ'),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanare OBD2 ELM327'),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isScanning ? Colors.orange.shade50 : 
                       _connectedDevice != null ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isScanning ? Colors.orange : 
                         _connectedDevice != null ? Colors.green : Colors.blue,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isScanning ? Icons.bluetooth_searching :
                    _connectedDevice != null ? Icons.bluetooth_connected : Icons.bluetooth,
                    color: _isScanning ? Colors.orange :
                           _connectedDevice != null ? Colors.green : Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scan Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? _stopScan : _startScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isScanning ? Colors.orange : Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: Icon(
                      _isScanning ? Icons.stop : Icons.search,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isScanning ? 'OPREȘTE SCANAREA' : 'SCANEAZĂ OBD2',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Devices List
            if (_devices.isNotEmpty) ...[
              const Text(
                'Dispozitive OBD2 Găsite:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Device List
            Expanded(
              child: _devices.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Niciun dispozitiv OBD2 găsit',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Asigură-te că adaptorul OBD2 este pornit',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        return _buildDeviceCard(_devices[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }
}
