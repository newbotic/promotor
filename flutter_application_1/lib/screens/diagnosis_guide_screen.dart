import 'package:flutter/material.dart';
import '../models/car_problem.dart';
import '../widgets/diagnosis_step_widget.dart';

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
  String obdData = 'ApasÄƒ butonul pentru a simula date OBD2';
  bool showOBDData = false;

  @override
  Widget build(BuildContext context) {
    final steps = widget.problem.steps;
    final currentDiagnosisStep = steps[currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header cu progres - REPARAT
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Pasul \${currentStep + 1}/\${steps.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\${((currentStep + 1) / steps.length * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // LinearProgressIndicator cu dimensiuni fixe
                  SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: (currentStep + 1) / steps.length,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
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
                    'ï¿½ï¿½ Simptome identificate:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.problem.symptoms.map((symptom) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('â€¢ \$symptom'),
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
            
            // Sectiune OBD2 SimulatÄƒ - doar pentru paÈ™ii OBD
            if (currentDiagnosisStep.type == 'obd') ...[
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
                        Icon(Icons.computer, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'í´§ Diagnostic OBD2',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showOBDData = true;
                          obdData = _getOBDDataForProblem(widget.problem.id);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'SIMULEAZÄ‚ CITIRE OBD2',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    if (showOBDData) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          obdData,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
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
                          showOBDData = false;
                        });
                      },
                      child: const Text('PASUL ANTERIOR'),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentStep < steps.length - 1
                        ? () {
                            setState(() {
                              currentStep++;
                              showOBDData = false;
                            });
                          }
                        : () {
                            _showDiagnosisComplete(context);
                          },
                    child: Text(
                      currentStep < steps.length - 1 
                          ? 'URMÄ‚TORUL PAS' 
                          : 'FINALIZEAZÄ‚',
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

  String _getOBDDataForProblem(String problemId) {
    switch (problemId) {
      case '1': // Termostat
        return 'í¼¡ï¸ Temperatura motor: 45Â°C\níº€ RPM: 850\nâš ï¸ CreÈ™tere lentÄƒ - termostat blocat deschis';
      case '2': // Sonda Lambda
        return 'í¼¡ï¸ Temperatura: 87Â°C\níº€ RPM: 2100\nâš ï¸ SondÄƒ Lambda: 0.1V (scÄƒzut)';
      case '3': // EGR
        return 'í¼¡ï¸ Temperatura: 92Â°C\níº€ RPM: 750\nâš ï¸ EGR: debit 0% (blocat)';
      case '4': // Bobina
        return 'í¼¡ï¸ Temperatura: 85Â°C\níº€ RPM: 3200\nâš ï¸ Misfire cilindrul 3';
      case '5': // MAF
        return 'ï¿½ï¿½ï¸ Temperatura: 88Â°C\níº€ RPM: 1800\nâš ï¸ MAF: 2.1 g/s (instabil)';
      default:
        return 'Date OBD2 simulate cu succes!';
    }
  }

  void _showDiagnosisComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnostic Complet'),
        content: const Text('Ai parcurs toÈ›i paÈ™ii de diagnostic pentru aceastÄƒ problemÄƒ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
