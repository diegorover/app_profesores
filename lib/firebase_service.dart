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
  final adjustedDocumentCount = documentCount - 5;

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

// Función para guardar todas las respuestas en los documentos correspondientes
Future<void> guardarPrimeraRespuestaEnMedia(String profesorId, String asignatura, String trimestre) async {
  final collectionRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura)
      .collection(trimestre);

  final querySnapshot = await collectionRef.get();
  final List<List<String>> respuestasPorPregunta = List.generate(5, (_) => []);

  for (var doc in querySnapshot.docs) {
    if (doc.data().containsKey('respuestas')) {
      final respuestas = doc['respuestas'] as List<dynamic>;
      for (int i = 0; i < respuestas.length && i < 5; i++) {
        respuestasPorPregunta[i].add(respuestas[i].toString());
      }
    }
  }

  // Guardar las respuestas en los documentos correspondientes
  for (int i = 0; i < respuestasPorPregunta.length; i++) {
    final mediaDocRef = FirebaseFirestore.instance
        .collection('profesores')
        .doc(profesorId)
        .collection('Asignaturas')
        .doc(asignatura)
        .collection(trimestre)
        .doc('${i}_Media');

    for (int j = 0; j < respuestasPorPregunta[i].length; j++) {
      final nombreCampo = 'Respuesta${j + 1}';
      await mediaDocRef.update({nombreCampo: respuestasPorPregunta[i][j]});
    }
  }
}


Future<void> guardarPromedioDeRespuestasEnMedia(String profesorId, String asignatura, String trimestre) async {
  final collectionRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura)
      .collection(trimestre);

  final querySnapshot = await collectionRef.get();
  final List<int> sumaTotalPorPregunta = List.generate(5, (_) => 0);
  int documentCount = querySnapshot.docs.length - 5; // Excluir los documentos '0_Media', '1_Media', etc.

  final List<List<int>> respuestasPorPregunta = List.generate(5, (_) => []);

  for (var doc in querySnapshot.docs.where((doc) => !doc.id.contains('_Media'))) {
    if (doc.data().containsKey('respuestas')) {
      final respuestas = doc['respuestas'] as List<dynamic>;
      for (int i = 0; i < respuestas.length && i < 5; i++) {
        int respuesta = int.tryParse(respuestas[i].toString()) ?? 0;
        respuestasPorPregunta[i].add(respuesta);
        sumaTotalPorPregunta[i] += respuesta;
      }
    }
  }

  for (int i = 0; i < respuestasPorPregunta.length; i++) {
    double media = documentCount > 0 ? sumaTotalPorPregunta[i] / documentCount : 0;

    // Guardar la suma total y el promedio en el documento correspondiente
    final mediaDocRef = FirebaseFirestore.instance
        .collection('profesores')
        .doc(profesorId)
        .collection('Asignaturas')
        .doc(asignatura)
        .collection(trimestre)
        .doc('${i}_Media');

    await mediaDocRef.update({
      '0_Media': media,
      'sumaTotal': sumaTotalPorPregunta[i],
      'documentCount': documentCount,
    });

    // También guardar las respuestas individuales
    for (int j = 0; j < respuestasPorPregunta[i].length; j++) {
      final nombreCampo = 'Respuesta${j + 1}';
      await mediaDocRef.update({nombreCampo: respuestasPorPregunta[i][j]});
    }
  }
}
