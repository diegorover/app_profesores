import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase_service_lengua.dart';
import 'inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: Inicio(), // Cambia la pantalla inicial a Inicio
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
      await saveRespuestas(respuestas);
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
        future: getPreguntas(),
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