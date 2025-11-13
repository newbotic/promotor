import 'package:flutter/material.dart';
import 'problem_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Diagnostic DIY'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.car_repair,
                  size: 100,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Auto Diagnostic',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Diagnosticare simplƒÉ pentru ma»ôina ta',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  // Navigare DIRECTƒÇ fƒÉrƒÉ dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProblemListScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('√éNCEPE DIAGNOSTICUL'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Doar butonul "Despre aplica»õie" aratƒÉ dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Despre Auto Diagnostic'),
                      content: const Text(
                        'Aplica»õie pentru diagnostic auto DIY care combinƒÉ:\n\n'
                        'Ì¥ß Ghiduri pas-cu-pas\n'
                        'Ì≥ä Citire date OBD2\n'
                        'ÌæØ Sugestii personalizate\n\n'
                        'Perfect pentru pasiona»õii auto »ôi mecanicii amatori!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('√énchide'),
                        ),
                      ],
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text('Despre aplica»õie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
