import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inicio.dart';

class Preguntas extends StatefulWidget {
  final String asignatura;
  final String profesor;
  final String trimestre;

  const Preguntas({
    Key? key,
    required this.asignatura,
    required this.profesor,
    required this.trimestre,
  }) : super(key: key);

  @override
  _PreguntasState createState() => _PreguntasState();
}

class _PreguntasState extends State<Preguntas> {
  final Map<String, TextEditingController> _controllers = {};

  Future<List<String>> getPreguntas() async {
    final docRef = FirebaseFirestore.instance.collection('profesores').doc(widget.asignatura);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey(widget.trimestre)) {
        List<String> preguntas = List<String>.from(data[widget.trimestre]);
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

  Future<void> saveRespuestas(Map<String, String> respuestas) async {
    final docRef = FirebaseFirestore.instance.collection('profesores').doc('Respuestas_${widget.asignatura}_${widget.profesor}');
    final docSnapshot = await docRef.get();

    int newFieldNumber = 1;
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        // Encuentra el mayor número actual de 'Respuestas'
        for (var key in data.keys) {
          if (key.startsWith('Respuestas')) {
            final number = int.tryParse(key.replaceFirst('Respuestas', ''));
            if (number != null && number >= newFieldNumber) {
              newFieldNumber = number + 1;
            }
          }
        }
      }
    }

    // Nombre del nuevo campo de respuestas
    final newFieldName = 'Respuestas$newFieldNumber';

    // Actualiza el documento con el nuevo campo de respuestas
    await docRef.update({
      newFieldName: respuestas,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responde las preguntas'),
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
