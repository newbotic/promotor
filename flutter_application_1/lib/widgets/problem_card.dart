import 'package:flutter/material.dart';
import '../models/car_problem.dart';

class ProblemCard extends StatelessWidget {
  final CarProblem problem;
  final VoidCallback onTap;

  const ProblemCard({
    super.key,
    required this.problem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          _getProblemIcon(problem.category),
          color: Colors.blue.shade700,
        ),
        title: Text(
          problem.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          problem.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  IconData _getProblemIcon(String category) {
    switch (category) {
      case 'engine':
        return Icons.engineering;
      case 'electrical':
        return Icons.electrical_services;
      case 'cooling':
        return Icons.ac_unit;
      case 'fuel':
        return Icons.local_gas_station;
      default:
        return Icons.car_repair;
    }
  }
}
