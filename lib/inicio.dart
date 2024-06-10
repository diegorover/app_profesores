import 'dart:async';

import 'package:flutter/material.dart';
import 'firebase_service.dart'; // Asegúrate de importar firebase_service.dart
import 'seleccion_profesor.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final TextEditingController _profesorController = TextEditingController();

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Inicia el temporizador
    _startTimer();
  }

  @override
  void dispose() {
    // Cancela el temporizador al salir de la pantalla
    _timer.cancel();
    super.dispose();
  }

  // Función para iniciar el temporizador
  void _startTimer() {
    // Crea un temporizador que se repite cada minuto
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      // Llama a las funciones para guardar respuestas
      _guardarRespuestas('Lengua', 'Trimestre 1');
      _guardarRespuestas('Lengua', 'Trimestre 2');
      _guardarRespuestas('Lengua', 'Trimestre 3');
      _guardarRespuestas('Matematicas', 'Trimestre 1');
      _guardarRespuestas('Matematicas', 'Trimestre 2');
      _guardarRespuestas('Matematicas', 'Trimestre 3');
    });
  }

  void _navigateToProfesorSelection() {
    final profesor = _profesorController.text.trim();
    if (profesor.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeleccionProfesor(profesorId: '4kReqVo85w4yVWcviLGB'), // Actualiza según la lógica
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el nombre del profesor.')),
      );
    }
  }

  void _guardarRespuestas(String asignatura, String trimestre) async {
    try {
      await countDocumentsAndSave('4kReqVo85w4yVWcviLGB', asignatura, trimestre);
      await guardarPrimeraRespuestaEnMedia('4kReqVo85w4yVWcviLGB', asignatura, trimestre);
      await guardarPromedioDeRespuestasEnMedia('4kReqVo85w4yVWcviLGB', asignatura, trimestre);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar respuestas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresa el nombre del profesor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingresa el nombre del profesor',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _profesorController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Profesor',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _navigateToProfesorSelection();
              },
              child: const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}
