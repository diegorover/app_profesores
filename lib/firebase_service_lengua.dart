import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveRespuestas(Map<String, String> respuestas, String userId) async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc('Respuestas_Lengua');
  final userDocRef = docRef.collection('users').doc(userId);

  final docSnapshot = await userDocRef.get();

  if (docSnapshot.exists && (docSnapshot.data() != null)) {
    throw Exception('Cuestionario ya realizado');
  } else {
    await userDocRef.set({'respuestas': respuestas});
  }
}

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
