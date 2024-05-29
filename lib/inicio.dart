import 'package:flutter/material.dart';
import 'seleccion_profesor.dart';
import 'firebase_service.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final TextEditingController _profesorController = TextEditingController();

  void _navigateToProfesorSelection() async {
    final profesorNombre = _profesorController.text.trim();
    if (profesorNombre.isNotEmpty) {
      final profesorId = await getProfesorIdByNombre(profesorNombre);
      if (profesorId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeleccionProfesor(profesorId: profesorId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El profesor no existe en la base de datos.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el nombre del profesor.')),
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
