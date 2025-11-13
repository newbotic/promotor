import 'package:flutter/material.dart';
import '../models/car_problem.dart';
import '../widgets/diagnosis_step_widget.dart';
import '../services/obd_service.dart';

class DiagnosisGuideScreen extends StatefulWidget {
  final CarProblem problem;

  const DiagnosisGuideScreen({
    super.key,
    required this.problem,
  });

  @override
  State<DiagnosisGuideScreen> createState() => _DiagnosisGuideScreenState();
}

class _DiagnosisGuideScreenState extends State<DiagnosisGuideScreen> {
  int currentStep = 0;
  bool isLoading = false;
  String obdData = 'Apasă "SIMULEAZĂ OBD2" pentru a vedea datele';
  Map<String, String> problemData = {};

  @override
  void initState() {
    super.initState();
    _loadProblemData();
  }

  Future<void> _loadProblemData() async {
    setState(() {
      isLoading = true;
    });
    
    final data = await OBDService.getProblemSpecificData(widget.problem.id);
    
    setState(() {
      problemData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.problem.steps;
    final currentDiagnosisStep = steps[currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (currentStep > 0)
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () {
                setState(() {
                  currentStep--;
                });
              },
            ),
          if (currentStep < steps.length - 1)
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                setState(() {
                  currentStep++;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header cu progres
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'Pasul \${currentStep + 1}/\${steps.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  LinearProgressIndicator(
                    value: (currentStep + 1) / steps.length,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Simptomele problemei
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '��� Simptome identificate:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.problem.symptoms.map((symptom) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• \$symptom'),
                    )
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Pasul curent de diagnostic
            DiagnosisStepWidget(
              step: currentDiagnosisStep,
              stepNumber: currentStep + 1,
              isCurrentStep: true,
            ),
            
            const SizedBox(height: 20),
            
            // Sectiune OBD2 Simulată - AFIȘATĂ MEREU
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.computer, color: Colors.green, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '��� Diagnostic OBD2 (Simulat)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (isLoading)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Se încarcă datele OBD2...'),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        obdData,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _simulateOBDData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'SIMULEAZĂ OBD2',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _refreshAllData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Reîmprospătează',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Butoane de navigare
            Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'PASUL ANTERIOR',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentStep < steps.length - 1
                        ? () {
                            setState(() {
                              currentStep++;
                            });
                          }
                        : () {
                            _showDiagnosisComplete(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      currentStep < steps.length - 1 
                          ? 'URMĂTORUL PAS' 
                          : 'FINALIZEAZĂ DIAGNOSTIC',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateOBDData() async {
    setState(() {
      isLoading = true;
      obdData = 'Se conectează la OBD2...';
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    final diagnostic = problemData['diagnostic'] ?? 'Date OBD2 simulate cu succes!';
    
    setState(() {
      obdData = diagnostic;
      isLoading = false;
    });
  }

  Future<void> _refreshAllData() async {
    setState(() {
      isLoading = true;
      obdData = 'Reîmprospătare date...';
    });
    
    await _loadProblemData();
    await Future.delayed(const Duration(seconds: 1));
    
    final diagnostic = problemData['diagnostic'] ?? 'Date reîmprospătate!';
    
    setState(() {
      obdData = diagnostic;
      isLoading = false;
    });
  }

  void _showDiagnosisComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('��� Diagnostic Complet!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ai parcurs toți pașii de diagnostic pentru această problemă.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '��� Sfat: Pentru funcționalitate OBD2 reală, '
                'vom integra un adaptor Bluetooth OBD2 în versiunea următoare!',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
