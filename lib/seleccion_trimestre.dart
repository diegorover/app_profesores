import 'package:flutter/material.dart';
import 'preguntas.dart';

class SeleccionTrimestre extends StatelessWidget {
  final String profesorId;
  final String asignatura;

  const SeleccionTrimestre({Key? key, required this.profesorId, required this.asignatura}) : super(key: key);

  void _navigateToPreguntas(BuildContext context, String trimestre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Preguntas(profesorId: profesorId, asignatura: asignatura, trimestre: trimestre),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccione el trimestre'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToPreguntas(context, 'Trimestre 1'),
              child: const Text('1º Trimestre'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToPreguntas(context, 'Trimestre 2'),
              child: const Text('2º Trimestre'),
            ),
            ElevatedButton(
              onPressed: () => _navigateToPreguntas(context, 'Trimestre 3'),
              child: const Text('3º Trimestre'),
            ),
          ],
        ),
      ),
    );
  }
}
