import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  await calcularYGuardarMedia(profesorId, asignatura, trimestre);
}

// Función para calcular la media de las últimas 5 respuestas numéricas y guardarla en Firestore
Future<void> calcularYGuardarMedia(String profesorId, String asignatura, String trimestre) async {
  final collectionRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura)
      .collection(trimestre);

  final querySnapshot = await collectionRef.orderBy('timestamp', descending: true).limit(5).get();

  List<int> ultimasRespuestas = [];
  for (var doc in querySnapshot.docs) {
    List<int> respuestasNum = List<int>.from(doc.data()['respuestasNum'] ?? []);
    ultimasRespuestas.addAll(respuestasNum);
  }

  if (ultimasRespuestas.isNotEmpty) {
    double media = ultimasRespuestas.reduce((a, b) => a + b) / ultimasRespuestas.length;

    final valoracionesDocRef = FirebaseFirestore.instance
        .collection('profesores')
        .doc(profesorId)
        .collection('Asignaturas')
        .doc('Valoraciones')
        .collection(asignatura)
        .doc('Trimestre $trimestre');

    await valoracionesDocRef.set({'media': media});
  }
}

// Nueva función para recopilar todas las respuestas de todos los trimestres de todas las asignaturas y copiarlas a la ruta especificada
Future<void> copiarRespuestasAValoraciones(String profesorId) async {
  final asignaturas = await getAsignaturas(profesorId);

  for (final asignatura in asignaturas) {
    for (int trimestre = 1; trimestre <= 3; trimestre++) {
      final collectionRef = FirebaseFirestore.instance
          .collection('profesores')
          .doc(profesorId)
          .collection('Asignaturas')
          .doc(asignatura)
          .collection('Trimestre $trimestre');

      final querySnapshot = await collectionRef.get();

      for (var doc in querySnapshot.docs) {
        final respuestas = doc.data()['respuestas'] ?? [];
        final respuestasNum = doc.data()['respuestasNum'] ?? [];

        final valoracionesDocRef = FirebaseFirestore.instance
            .collection('profesores')
            .doc(profesorId)
            .collection('Asignaturas')
            .doc('Valoraciones')
            .collection(asignatura)
            .doc('Trimestre $trimestre');

        final existingData = await valoracionesDocRef.get();
        List<dynamic> existingRespuestas = [];
        List<dynamic> existingRespuestasNum = [];

        if (existingData.exists) {
          existingRespuestas = existingData.data()?['respuestas'] ?? [];
          existingRespuestasNum = existingData.data()?['respuestasNum'] ?? [];
        }

        existingRespuestas.addAll(respuestas);
        existingRespuestasNum.addAll(respuestasNum);

        await valoracionesDocRef.set({
          'respuestas': existingRespuestas,
          'respuestasNum': existingRespuestasNum,
        });
      }
    }
  }
}
