import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getProfesorIdByNombre(String nombre) async {
  final profesoresCollection = FirebaseFirestore.instance.collection('profesores');
  final querySnapshot = await profesoresCollection.doc('4kReqVo85w4yVWcviLGB').collection('Datos del Profesor').where('Nombre', isEqualTo: nombre).get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.id;
  }

  // Si no se encontraron coincidencias, intenta buscar en minúsculas
  final querySnapshotLowerCase = await profesoresCollection.doc('4kReqVo85w4yVWcviLGB').collection('Datos del Profesor').where('Nombre', isEqualTo: nombre.toLowerCase()).get();
  if (querySnapshotLowerCase.docs.isNotEmpty) {
    return querySnapshotLowerCase.docs.first.id;
  }

  return null;
}

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
