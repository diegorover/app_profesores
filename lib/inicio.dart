import 'package:flutter/material.dart';
import 'firebase_service_matematicas.dart';
import 'main.dart';
import 'firebase_service_lengua.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final TextEditingController _codeController = TextEditingController();

  void _navigateToHome() {
    if (_codeController.text == '1') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else if (_codeController.text == '2') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeMatematicas()),
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

class HomeMatematicas extends StatefulWidget {
  const HomeMatematicas({super.key});

  @override
  State<HomeMatematicas> createState() => _HomeMatematicasState();
}

class _HomeMatematicasState extends State<HomeMatematicas> {
  final Map<String, TextEditingController> _controllers = {};

  Future<void> _submitRespuestas() async {
    bool allFilled = true;
    _controllers.forEach((key, controller) {
      if (controller.text.isEmpty) {
        allFilled = false;
      }
    });

    if (!allFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, responde todas las preguntas.')),
      );
      return;
    }

    final respuestas = _controllers.map((key, value) => MapEntry(key, value.text));
    try {
      await saveRespuestasMatematicas(respuestas);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respuestas guardadas exitosamente')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Inicio()), // Redirigir a la página de inicio
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar respuestas: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material App Bar'),
        automaticallyImplyLeading: false, // Deshabilitar el botón de regreso
      ),
      body: FutureBuilder<List<String>>(
        future: getPreguntasMatematicas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay preguntas disponibles.'));
          } else {
            final preguntas = snapshot.data!;
            for (var pregunta in preguntas) {
              _controllers[pregunta] = TextEditingController();
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: preguntas.length,
                    itemBuilder: (context, index) {
                      final pregunta = preguntas[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pregunta),
                            TextField(
                              controller: _controllers[pregunta],
                              decoration: const InputDecoration(
                                hintText: 'Escribe tu respuesta aquí',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitRespuestas,
                  child: const Text('Enviar respuestas'),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}
