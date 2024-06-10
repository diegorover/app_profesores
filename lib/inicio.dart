import 'package:flutter/material.dart';
import 'firebase_service.dart'; // Asegúrate de importar firebase_service.dart
import 'seleccion_profesor.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final TextEditingController _profesorController = TextEditingController();

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

  void _guardarRespuestas() async {
    try {
      const String asignatura = 'Lengua';
      const String trimestre = 'Trimestre 1';

      await countDocumentsAndSave('4kReqVo85w4yVWcviLGB', asignatura, trimestre);
      await guardarPrimeraRespuestaEnMedia('4kReqVo85w4yVWcviLGB', asignatura, trimestre);
      await guardarPromedioDeRespuestasEnMedia('4kReqVo85w4yVWcviLGB', asignatura, trimestre);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respuestas guardadas exitosamente para Lengua en Trimestre 1')),
      );
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
              onPressed: _navigateToProfesorSelection,
              child: const Text('Ingresar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardarRespuestas,
              child: const Text('Guardar Respuestas'),
            ),
          ],
        ),
      ),
    );
  }
}
