import 'package:flutter/material.dart';
import 'descargar_respuestas_matematicas.dart';
import 'descargar_respuestas.dart'; // Importa también el widget de DescargarRespuestas para Lengua

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final TextEditingController _codeController = TextEditingController();

  void _navigateToHome() {
    if (_codeController.text == '1') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DescargarRespuestas(profesor: 'Juan', trimestre: 1),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DescargarRespuestasMatematicas(profesor: 'Ana', trimestre: 1),
        ),
      );
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

