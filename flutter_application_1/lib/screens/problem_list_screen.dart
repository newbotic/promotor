import 'package:flutter/material.dart';
import '../models/car_problem.dart';
import '../widgets/problem_card.dart';
import 'diagnosis_guide_screen.dart';

class ProblemListScreen extends StatelessWidget {
  const ProblemListScreen({super.key});

  final List<CarProblem> problems = const [
    CarProblem(
      id: '1',
      title: 'Termostat blocat deschis',
      description: 'Motorul nu ajunge la temperatura optimă',
      category: 'cooling',
      symptoms: ['Motorul se încălzește foarte lent'],
      steps: [
        DiagnosisStep(
          title: 'Verificare temperatură',
          description: 'Monitorizează temperatura motorului',
          type: 'obd',
          instructions: ['Pornește motorul rece', 'Monitorizează temperatura'],
          expectedResult: 'Temperatura crește rapid',
        ),
      ],
    ),
    CarProblem(
      id: '2',
      title: 'Sondă Lambda defectă',
      description: 'Problemă la senzorul de oxigen',
      category: 'engine',
      symptoms: ['Consum crescut de combustibil'],
      steps: [
        DiagnosisStep(
          title: 'Citire coduri eroare',
          description: 'Verifică codurile OBD2',
          type: 'obd',
          instructions: ['Conectează-te la OBD2', 'Citește codurile'],
          expectedResult: 'Niciun cod de eroare',
        ),
      ],
    ),
    CarProblem(
      id: '3',
      title: 'EGR blocată',
      description: 'Sistem EGR nu funcționează corect',
      category: 'engine',
      symptoms: ['Motorul merge neregulat'],
      steps: [
        DiagnosisStep(
          title: 'Verificare vizuală',
          description: 'Inspectează supapa EGR',
          type: 'visual',
          instructions: ['Localizează supapa EGR'],
          expectedResult: 'Supapa curată',
        ),
      ],
    ),
    CarProblem(
      id: '4',
      title: 'Bobina defectă',
      description: 'Problemă la sistemul de aprindere',
      category: 'electrical',
      symptoms: ['Motorul "scapără"'],
      steps: [
        DiagnosisStep(
          title: 'Testare bobine',
          description: 'Verifică misfire',
          type: 'obd',
          instructions: ['Conectează-te la OBD2'],
          expectedResult: 'Niciun misfire',
        ),
      ],
    ),
    CarProblem(
      id: '5',
      title: 'Senzor MAF murdar',
      description: 'Senzor debitmetru aer necesita curățare',
      category: 'engine',
      symptoms: ['Acceleratie neregulată'],
      steps: [
        DiagnosisStep(
          title: 'Verificare date MAF',
          description: 'Monitorizează debitul de aer',
          type: 'obd',
          instructions: ['Conectează-te la OBD2'],
          expectedResult: 'Valori MAF stabile',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alege Problema'),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        itemCount: problems.length,
        itemBuilder: (context, index) {
          final problem = problems[index];
          return ProblemCard(
            problem: problem,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiagnosisGuideScreen(problem: problem),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
