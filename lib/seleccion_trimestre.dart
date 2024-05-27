import 'package:flutter/material.dart';
import 'cuestionario.dart';
import 'descargar_respuestas.dart';

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

  void _navigateToDescargarRespuestas(BuildContext context, int trimestre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DescargarRespuestas(profesor: profesor, trimestre: trimestre),
      ),
    );
  }

  void _showTrimestreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un trimestre para descargar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('1º Trimestre'),
                onTap: () {
                  _navigateToDescargarRespuestas(context, 1);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('2º Trimestre'),
                onTap: () {
                  _navigateToDescargarRespuestas(context, 2);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('3º Trimestre'),
                onTap: () {
                  _navigateToDescargarRespuestas(context, 3);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showTrimestreDialog(context),
              child: const Text('Descargar respuestas'),
            ),
          ],
        ),
      ),
    );
  }
}
