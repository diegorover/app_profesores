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
  final Map<String, String> _selectedValues = {};

  Future<List<String>> _getPreguntas() async {
    return await getPreguntas(widget.profesorId, widget.asignatura, widget.trimestre);
  }

  Future<void> _submitRespuestas() async {
    bool allFilled = true;
    _controllers.forEach((key, controller) {
      if (controller.text.isEmpty) {
        allFilled = false;
      }
    });

    _selectedValues.forEach((key, value) {
      if (value.isEmpty) {
        allFilled = false;
      }
    });

    if (!allFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, responde todas las preguntas.')),
      );
      return;
    }

    final respuestas = <String>[];
    final respuestasNum = <String>[];

    _controllers.forEach((key, controller) {
      if (!key.startsWith('_num')) {
        respuestas.add(controller.text);
      }
    });

    _selectedValues.forEach((key, value) {
      if (key.startsWith('_num')) {
        respuestasNum.add(value);
      }
    });

    try {
      await saveRespuestas(widget.profesorId, widget.asignatura, widget.trimestre, respuestas, respuestasNum);
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
    if (!pregunta.startsWith('_num')) {
    _controllers[pregunta] = TextEditingController();
    } else {
    _selectedValues[pregunta] = '';
    }
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
    pregunta.startsWith('_num') ? pregunta.substring(5) : pregunta,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
      if (pregunta.startsWith('_num')) // Check if the question is numeric
        DropdownButton<String>(
          value: _selectedValues[pregunta],
          items: List.generate(10, (i) => (i + 1).toString())
              .map((value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ))
              .toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedValues[pregunta] = newValue ?? '';
            });
          },
          hint: const Text('Selecciona un número del 1 al 10'),
        )
      else
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

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}