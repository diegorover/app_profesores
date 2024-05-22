import 'package:flutter/material.dart';
import 'firebase_service_matematicas.dart';
import 'main.dart';
import 'firebase_service_lengua.dart';

// Añadir esta función para verificar si el cuestionario ya ha sido completado
Future<bool> isCuestionarioCompletado(String codigo) async {
  // Aquí debes agregar la lógica para verificar en Firestore si el cuestionario ya ha sido completado
  // Por ejemplo, podrías verificar si existe un documento con el código correspondiente en una colección de respuestas.
  // Devuelve true si el cuestionario está completado, de lo contrario, devuelve false.
}

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final TextEditingController _codeController = TextEditingController();

  void _navigateToHome() async {
    bool cuestionarioCompletado = await isCuestionarioCompletado(_codeController.text);
    if (_codeController.text == '1') {
      if (cuestionarioCompletado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuestionario ya realizado')),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } else if (_codeController.text == '2') {
      if (cuestionarioCompletado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuestionario ya realizado')),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeMatematicas()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código incorrecto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresa el código del cuestionario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingresa el código del cuestionario',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Código',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToHome,
              child: const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}

