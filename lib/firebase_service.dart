import 'package:cloud_firestore/cloud_firestore.dart';

// Función para obtener los nombres de las asignaturas dentro de un documento de profesor
Future<List<String>> getAsignaturas(String profesorId) async {
  final profesorDocRef = FirebaseFirestore.instance.collection('profesores').doc(profesorId);
  final snapshot = await profesorDocRef.get();

  if (!snapshot.exists) {
    return [];
  }

  final asignaturas = await FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .get()
      .then((doc) => doc.reference.collection('Asignaturas').get());

  List<String> asignaturasList = [];
  for (var doc in asignaturas.docs) {
    asignaturasList.add(doc.id);
  }

  return asignaturasList;
}

// Función para obtener las preguntas del profesor
Future<List<String>> getPreguntas(String profesorId) async {
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
  final asignaturaDocRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc(asignatura); // Utilizar el nombre de la asignatura proporcionado

  final snapshot = await asignaturaDocRef.get();

  if (snapshot.exists) {
    final trimestreDocId = snapshot.data()![trimestre];
    if (trimestreDocId != null) {
      final trimestreDocRef = asignaturaDocRef.collection('collections').doc(trimestreDocId);
      await trimestreDocRef.update({trimestre: FieldValue.arrayUnion(respuestas)});
    }
  }
}
