import 'package:flutter/material.dart';
import 'cuestionario.dart';

class SeleccionTrimestre extends StatelessWidget {
  final String asignatura;
  final String profesor;

  const SeleccionTrimestre({Key? key, required this.asignatura, required this.profesor}) : super(key: key);

  void _navigateToCuestionario(BuildContext context, int trimestre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cuestionario(asignatura: asignatura, profesor: profesor, trimestre: trimestre),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccione el trimestre de $profesor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToCuestionario(context, 1),
              child: const Text('1º Trimestre'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToCuestionario(context, 2),
              child: const Text('2º Trimestre'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToCuestionario(context, 3),
              child: const Text('3º Trimestre'),
            ),
          ],
        ),
      ),
    );
  }
}

