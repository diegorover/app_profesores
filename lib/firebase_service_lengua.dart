import 'package:cloud_firestore/cloud_firestore.dart';

// Función para obtener las preguntas del documento "Lengua"
Future<List<String>> getPreguntas() async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc('lengua');
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

// Función para guardar las respuestas en Firestore
Future<void> saveRespuestas(Map<String, String> respuestas) async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc('Respuestas_Lengua');
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

