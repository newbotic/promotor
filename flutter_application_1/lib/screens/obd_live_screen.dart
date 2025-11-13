import 'package:flutter/material.dart';
import '../services/obd_service.dart';

class OBDLiveScreen extends StatefulWidget {
  const OBDLiveScreen({super.key});

  @override
  State<OBDLiveScreen> createState() => _OBDLiveScreenState();
}

class _OBDLiveScreenState extends State<OBDLiveScreen> {
  bool isConnected = false;
  bool isLoading = false;
  Map<String, String> liveData = {};
  List<String> troubleCodes = [];

  @override
  void initState() {
    super.initState();
    _connectToOBD();
  }

  Future<void> _connectToOBD() async {
    setState(() {
      isLoading = true;
    });

    // SimuleazƒÉ conexiunea OBD2
    await Future.delayed(const Duration(seconds: 2));
    
    final connected = await OBDService.connectToOBD();
    
    setState(() {
      isConnected = connected;
      isLoading = false;
    });

    if (connected) {
      _startLiveData();
    }
  }

  Future<void> _startLiveData() async {
    while (isConnected) {
      await _updateLiveData();
      await Future.delayed(const Duration(seconds: 2)); // Update la fiecare 2 secunde
    }
  }

  Future<void> _updateLiveData() async {
    if (!isConnected) return;

    final temp = await OBDService.getEngineTemp();
    final rpm = await OBDService.getEngineRPM();
    final codes = await OBDService.getTroubleCodes();

    setState(() {
      liveData = {
        'Ìº°Ô∏è TemperaturƒÉ motor': temp,
        'Ì∫Ä RPM motor': rpm,
        'Ì≤® Viteza vehicul': '65 km/h',
        '‚õΩ Consum instant': '8.2 L/100km',
        'Ì¥ã Tensiune baterie': '14.2V',
        'ÔøΩÔøΩÔ∏è Presiune admisie': '101.3 kPa',
      };
      troubleCodes = codes;
    });
  }

  Future<void> _disconnectOBD() async {
    setState(() {
      isConnected = false;
      isLoading = false;
      liveData = {};
      troubleCodes = [];
    });
    
    await OBDService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD2 Live Data'),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: isConnected ? _updateLiveData : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status conexiune
            _buildConnectionStatus(),
            
            const SizedBox(height: 20),
            
            // Date live
            _buildLiveDataSection(),
            
            const SizedBox(height: 20),
            
            // Coduri eroare
            _buildTroubleCodesSection(),
            
            const Spacer(),
            
            // Butoane ac»õiune
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLoading ? Colors.orange.shade50 : 
               isConnected ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoading ? Colors.orange : 
                 isConnected ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLoading ? Icons.bluetooth_searching :
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isLoading ? Colors.orange :
                   isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? 'Se conecteazƒÉ la OBD2...' :
                  isConnected ? 'CONECTAT la OBD2' : 'DECONECTAT de la OBD2',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isConnected) ...[
                  const SizedBox(height: 4),
                  Text(
                    'VIN: WVWZZZ1KZ8W000000',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDataSection() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ì≥à Date √Æn timp real',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: liveData.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.computer, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Nu sunt date disponibile',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: liveData.length,
                    itemBuilder: (context, index) {
                      final key = liveData.keys.elementAt(index);
                      final value = liveData[key]!;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              value,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
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

  Widget _buildTroubleCodesSection() {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '‚ö†Ô∏è Coduri de eroare',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: troubleCodes.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Center(
                      child: Text(
                        '‚úÖ Niciun cod de eroare detectat',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: troubleCodes.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                troubleCodes[index],
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isConnected ? _disconnectOBD : _connectToOBD,
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? Colors.red : Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              isConnected ? 'DECONECTEAZƒÇ' : 'CONECTEAZƒÇ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: isConnected ? _updateLiveData : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('RE√éMPROSPƒÇTEAZƒÇ'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _disconnectOBD();
    super.dispose();
  }
}
