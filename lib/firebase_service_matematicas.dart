import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getPreguntasMatematicas() async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc('matematicas');
  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    if (data != null && data.containsKey('Preguntas')) {
      List<String> preguntas = List<String>.from(data['Preguntas']);
      return preguntas.length > 5 ? preguntas.sublist(0, 5) : preguntas;
    }
  }
  return [];
}

Future<void> saveRespuestasMatematicas(Map<String, String> respuestas) async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc('Respuestas_Matematicas');
  final docSnapshot = await docRef.get();

  int newFieldNumber = 1;
  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    if (data != null) {
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

  final newFieldName = 'Respuestas$newFieldNumber';
  await docRef.update({
    newFieldName: respuestas,
  });
}
