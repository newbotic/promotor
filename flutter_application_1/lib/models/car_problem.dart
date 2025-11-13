class CarProblem {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> symptoms;
  final List<DiagnosisStep> steps;

  const CarProblem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.symptoms,
    required this.steps,
  });
}

class DiagnosisStep {
  final String title;
  final String description;
  final String type; // 'visual', 'obd', 'mechanical'
  final List<String> instructions;
  final String? expectedResult;

  const DiagnosisStep({
    required this.title,
    required this.description,
    required this.type,
    required this.instructions,
    this.expectedResult,
  });
}
