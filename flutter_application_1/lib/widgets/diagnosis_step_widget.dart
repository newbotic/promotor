import 'package:flutter/material.dart';
import '../models/car_problem.dart';

class DiagnosisStepWidget extends StatelessWidget {
  final DiagnosisStep step;
  final int stepNumber;
  final bool isCurrentStep;

  const DiagnosisStepWidget({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.isCurrentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentStep ? Colors.blue.shade50 : Colors.grey.shade50,
        border: Border.all(
          color: isCurrentStep ? Colors.blue : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCurrentStep ? Colors.blue : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentStep ? Colors.blue.shade800 : Colors.grey.shade800,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                _getStepIcon(step.type),
                color: isCurrentStep ? Colors.blue : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...step.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${index + 1}. '),
                  Expanded(child: Text(instruction)),
                ],
              ),
            );
          }),
          if (step.expectedResult != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rezultat așteptat: ${step.expectedResult}',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStepIcon(String type) {
    switch (type) {
      case 'obd':
        return Icons.computer;
      case 'visual':
        return Icons.remove_red_eye;
      case 'mechanical':
        return Icons.build;
      default:
        return Icons.help;
    }
  }
}
