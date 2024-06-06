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

Future<void> actualizarRespuesta1() async {
  final String profesorId = '4kReqVo85w4yVWcviLGB';
  final String asignatura = 'Lengua';
  final String trimestre = 'Trimestre 1';
  final String documentoId = '2lW8cex38W3dFwyvNbMh';

  final documentRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura)
      .collection(trimestre)
      .doc(documentoId);

  final documentSnapshot = await documentRef.get();

  if (documentSnapshot.exists) {
    final respuestas = documentSnapshot.data()!['respuestas'];
    final valorPosicion0 = respuestas[0];

    final mediaDocRef = FirebaseFirestore.instance
        .collection('profesores')
        .doc(profesorId)
        .collection('Asignaturas')
        .doc(asignatura)
        .collection(trimestre)
        .doc('0_Media');

    await mediaDocRef.set({'Respuesta1': valorPosicion0}, SetOptions(merge: true));
    print('Valor de la posición 0 guardado en 0_Media con el nombre Respuesta1');
  } else {
    print('El documento $documentoId no existe en la ruta especificada');
  }
}