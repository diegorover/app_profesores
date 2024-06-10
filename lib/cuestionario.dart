import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_service.dart';
import 'inicio.dart';

class Cuestionario extends StatefulWidget {
  final String asignatura;
  final String profesor;
  final int trimestre;

  const Cuestionario({
    Key? key,
    required this.asignatura,
    required this.profesor,
    required this.trimestre,
  }) : super(key: key);

  @override
  _CuestionarioState createState() => _CuestionarioState();
}

class _CuestionarioState extends State<Cuestionario> {
  final Map<String, TextEditingController> _controllers = {};

  Future<List<String>> getPreguntas() async {
    final docRef = FirebaseFirestore.instance.collection('profesores').doc('4kReqVo85w4yVWcviLGB');
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('Preguntas')) {
        List<String> preguntas = List<String>.from(data['Preguntas']);
        // Asegúrate de que solo retornamos 5 preguntas
        return preguntas.length > 5 ? preguntas.sublist(0, 5) : preguntas;
      }
    }
    return [];
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

    final respuestas = _controllers.map((key, value) => MapEntry(key, value.text));
    try {
      final docRef = FirebaseFirestore.instance.collection('profesores').doc('4kReqVo85w4yVWcviLGB');
      final fieldName = 'Respuestas Trimestre ${widget.trimestre} ${widget.profesor}';

      await docRef.update({
        fieldName: respuestas,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respuestas guardadas exitosamente')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Inicio()), // Redirigir a la página de inicio
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar respuestas: $e')));
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
        title: Text('Cuestionario Trimestre ${widget.trimestre} - ${widget.profesor}'),
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
                  onPressed: () {
                    _submitRespuestas();
                  },
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
