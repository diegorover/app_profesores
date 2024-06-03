import 'package:cloud_firestore/cloud_firestore.dart';

// Función para obtener las asignaturas de un profesor específico
Future<List<String>> getAsignaturas(String profesorId) async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc('4kReqVo85w4yVWcviLGB');
  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    if (data != null && data.containsKey('TipoAsig')) {
      List<String> asignaturas = List<String>.from(data['TipoAsig']);
      return asignaturas;
    }
  }
  return [];
}

// Función para obtener las preguntas del profesor
Future<List<String>> getPreguntas(String profesorId, String asignatura, String trimestre) async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc(profesorId);
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

// Función para guardar las respuestas en Firestore
Future<void> saveRespuestas(String profesorId, String asignatura, String trimestre, List<String> respuestas) async {
  final docRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura)
      .collection(trimestre)
      .doc();

  await docRef.set({'respuestas': respuestas});
}
