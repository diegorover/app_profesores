import 'package:flutter/material.dart';
import 'preguntas.dart';

class SeleccionTrimestre extends StatelessWidget {
  final String profesorId;
  final String asignatura;

  const SeleccionTrimestre({
    Key? key,
    required this.profesorId,
    required this.asignatura,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona el Trimestre para $asignatura'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Preguntas(
                      profesorId: profesorId,
                      asignatura: asignatura,
                      trimestre: 'Trimestre 1',
                    ),
                  ),
                );
              },
              child: Text('Trimestre 1'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Preguntas(
                      profesorId: profesorId,
                      asignatura: asignatura,
                      trimestre: 'Trimestre 2',
                    ),
                  ),
                );
              },
              child: Text('Trimestre 2'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Preguntas(
                      profesorId: profesorId,
                      asignatura: asignatura,
                      trimestre: 'Trimestre 3',
                    ),
                  ),
                );
              },
              child: Text('Trimestre 3'),
            ),
          ],
        ),
      ),
    );
  }
}