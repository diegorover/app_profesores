import 'package:flutter/material.dart';
import 'firebase_service.dart';
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

  Future<void> _copiarRespuestas() async {
    await copiarRespuestasAValoraciones('4kReqVo85w4yVWcviLGB');
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respuestas copiadas exitosamente a Valoraciones'))
    );
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
              onPressed: _copiarRespuestas,
              child: const Text('Copiar Respuestas a Valoraciones'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _profesorController.dispose();
    super.dispose();
  }
}
