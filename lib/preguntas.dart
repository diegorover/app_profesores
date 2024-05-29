import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'inicio.dart';

class Preguntas extends StatefulWidget {
  final String profesorId;
  final String asignatura;
  final String trimestre;

  const Preguntas({
    Key? key,
    required this.profesorId,
    required this.asignatura,
    required this.trimestre,
  }) : super(key: key);

  @override
  _PreguntasState createState() => _PreguntasState();
}

class _PreguntasState extends State<Preguntas> {
  final Map<String, TextEditingController> _controllers = {};

  Future<List<String>> _getPreguntas() async {
    return await getPreguntas(widget.profesorId);
  }

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

    final respuestas = _controllers.values.map((controller) => controller.text).toList();
    try {
      await saveRespuestas(widget.profesorId, widget.asignatura, widget.trimestre, respuestas);
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
        title: const Text('Responde las preguntas'),
      ),
      body: FutureBuilder<List<String>>(
        future: _getPreguntas(),
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: preguntas.length,
                      itemBuilder: (context, index) {
                        final pregunta = preguntas[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pregunta,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _controllers[pregunta],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
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
                    child: const Text('Guardar respuestas'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}