import 'package:cloud_firestore/cloud_firestore.dart';

// Función para contar documentos en una colección y guardar el número en 0_Media
Future<void> countDocumentsAndSave(String profesorId, String asignatura, String trimestre) async {
  final collectionRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura)
      .collection(trimestre);

  final querySnapshot = await collectionRef.get();
  final documentCount = querySnapshot.docs.length;

  // Restar uno al conteo total
  final adjustedDocumentCount = documentCount - 1;

  final mediaDocRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura)
      .collection(trimestre)
      .doc('0_Media');

  await mediaDocRef.update({'documentCount': adjustedDocumentCount});
}

// Función para obtener las preguntas del profesor
Future<List<String>> getPreguntas(String profesorId, String asignatura, String trimestre) async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc(profesorId);
  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    if (data != null) {
      List<String> preguntas = [];
      if (data.containsKey('Preguntas')) {
        preguntas.addAll(List<String>.from(data['Preguntas']));
      }
      if (data.containsKey('PreguntasNum')) {
        preguntas.addAll(List<String>.from(data['PreguntasNum']));
      }
      return preguntas.length > 10 ? preguntas.sublist(0, 10) : preguntas;
    }
  }
  return [];
}

// Función para obtener las asignaturas de un profesor específico
Future<List<String>> getAsignaturas(String profesorId) async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc(profesorId);
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

// Función para guardar las respuestas en Firestore
Future<void> saveRespuestas(String profesorId, String asignatura, String trimestre, List<String> respuestas, List<String> respuestasNum) async {
  final docRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura)
      .collection(trimestre)
      .doc();

  await docRef.set({
    'respuestas': respuestas,
    'respuestasNum': respuestasNum.map((e) => int.parse(e)).toList(),
    'timestamp': FieldValue.serverTimestamp()
  });

}

Future<void> guardarRespuestas(String profesorId) async {
  final collectionRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc('Lengua')
      .collection('Trimestre 1');

  final querySnapshot = await collectionRef.get();
  final respuestas = querySnapshot.docs.map((doc) {
    final respuestas = doc['respuestas'] as List<dynamic>;
    return respuestas.isNotEmpty ? respuestas[0].toString() : ''; // Obtener la primera respuesta del array
  }).toList();

  // Guardar las respuestas en 0_Media
  final mediaDocRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc('Lengua')
      .collection('Trimestre 1')
      .doc('0_Media');

  for (int i = 0; i < respuestas.length; i++) {
    final nombreCampo = 'Respuesta${i + 1}';
    await mediaDocRef.update({nombreCampo: respuestas[i]});
  }
}
