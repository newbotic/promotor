import 'package:flutter/material.dart';
import '../models/car_problem.dart';
import '../widgets/problem_card.dart';
import 'diagnosis_guide_screen.dart';

class ProblemListScreen extends StatelessWidget {
  const ProblemListScreen({super.key});

  // Date mock - vor fi înlocuite cu date reale
  final List<CarProblem> problems = const [
    CarProblem(
      id: '1',
      title: 'Termostat blocat deschis',
      description: 'Motorul nu ajunge la temperatura optimă',
      category: 'cooling',
      symptoms: [
        'Motorul se încălzește foarte lent',
        'Încălzirea habitaclului funcționează prost',
        'Consum crescut de combustibil',
      ],
      steps: [
        DiagnosisStep(
          title: 'Verificare temperatură OBD2',
          description: 'Monitorizează temperatura motorului',
          type: 'obd',
          instructions: [
            'Conectează-te la OBD2 cu motorul rece',
            'Pornește motorul și lasă-l la ralanti',
            'Monitorizează temperatura în primii 10 minute',
          ],
          expectedResult: 'Temperatura crește rapid la 80-90°C',
        ),
      ],
    ),
    CarProblem(
      id: '2',
      title: 'Sondă Lambda defectă',
      description: 'Problemă la senzorul de oxigen',
      category: 'engine',
      symptoms: [
        'Consum crescut de combustibil',
        'Putere redusă la acceleratie',
        'Eroare Check Engine',
      ],
      steps: [
        DiagnosisStep(
          title: 'Citire coduri eroare OBD2',
          description: 'Verifică dacă există coduri pentru sondă lambda',
          type: 'obd',
          instructions: [
            'Conectează-te la OBD2',
            'Citește codurile de eroare',
            'Notează orice cod P0130-P0167',
          ],
          expectedResult: 'Niciun cod de eroare pentru sonda lambda',
        ),
      ],
    ),
    CarProblem(
      id: '3',
      title: 'EGR blocată',
      description: 'Sistem EGR nu funcționează corect',
      category: 'engine',
      symptoms: [
        'Motorul merge neregulat la ralanti',
        'Pierdere de putere',
        'Fum negru la eșapament',
      ],
      steps: [
        DiagnosisStep(
          title: 'Verificare vizuală EGR',
          description: 'Inspectează vizual supapa EGR',
          type: 'visual',
          instructions: [
            'Localizează supapa EGR pe motor',
            'Verifică conexiunile și furtunele',
            'Caută urme de carbon sau depuneri',
          ],
          expectedResult: 'Supapa curată și conexiuni etanșe',
        ),
      ],
    ),
    CarProblem(
      id: '4',
      title: 'Bobina de aprindere defectă',
      description: 'Problemă la sistemul de aprindere',
      category: 'electrical',
      symptoms: [
        'Motorul "scapără" sau tremură',
        'Pierdere de putere',
        'Consum crescut',
      ],
      steps: [
        DiagnosisStep(
          title: 'Testare bobine OBD2',
          description: 'Verifică misfire cu OBD2',
          type: 'obd',
          instructions: [
            'Conectează-te la OBD2',
            'Citește codurile de misfire (P0300-P0308)',
            'Monitorizează datele în timp real la acceleratie',
          ],
          expectedResult: 'Niciun misfire detectat',
        ),
      ],
    ),
    CarProblem(
      id: '5',
      title: 'Senzor MAF murdar',
      description: 'Senzor debitmetru aer necesita curățare',
      category: 'engine',
      symptoms: [
        'Acceleratie neregulată',
        'Motorul se oprește la ralanti',
        'Consum crescut',
      ],
      steps: [
        DiagnosisStep(
          title: 'Verificare date MAF OBD2',
          description: 'Monitorizează debitul de aer',
          type: 'obd',
          instructions: [
            'Conectează-te la OBD2',
            'Citește valorile MAF la ralanti',
            'Verifică valorile la acceleratie bruscă',
          ],
          expectedResult: 'Valori MAF stabile și în parametri normali',
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
