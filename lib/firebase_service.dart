import 'package:cloud_firestore/cloud_firestore.dart';

// Función para obtener las preguntas numéricas del profesor
Future<List<String>> getPreguntas(String profesorId, String asignatura, String trimestre) async {
  final docRef = FirebaseFirestore.instance.collection('profesores').doc(profesorId);
  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    if (data != null && data.containsKey('PreguntasNum')) {
      List<String> preguntasNum = List<String>.from(data['PreguntasNum']);
      return preguntasNum.length > 10 ? preguntasNum.sublist(0, 10) : preguntasNum;
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

  final Map<String, dynamic> data = {
    'timestamp': FieldValue.serverTimestamp(),
  };

  for (var i = 0; i < respuestas.length; i++) {
    final pregunta = respuestas[i];
    if (pregunta.startsWith('_num')) {
      data[pregunta] = int.parse(respuestasNum[i]);
    } else {
      data[pregunta] = respuestas[i];
    }
  }

  await docRef.set(data);

}

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

Future<void> calcularYGuardarMediaRespuesta1(String profesorId, String trimestre) async {
  final collectionRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc('Lengua')
      .collection(trimestre);

  // Obtener todos los documentos dentro de la colección
  final querySnapshot = await collectionRef.get();

  // Inicializar listas para almacenar las respuestas
  List<int> respuestas1 = [];
  List<int> respuestas2 = [];
  List<int> respuestas3 = [];
  List<int> respuestas4 = [];
  List<int> respuestas5 = [];

  // Iterar sobre los documentos y almacenar las respuestas
  querySnapshot.docs.forEach((doc) {
    respuestas1.add(doc.data()['Respuesta 1'] ?? 0); // Se usa el valor predeterminado 0 si no hay respuesta
    respuestas2.add(doc.data()['Respuesta 2'] ?? 0);
    respuestas3.add(doc.data()['Respuesta 3'] ?? 0);
    respuestas4.add(doc.data()['Respuesta 4'] ?? 0);
    respuestas5.add(doc.data()['Respuesta 5'] ?? 0);
  });

  // Calcular la media de las respuestas
  double mediaRespuesta1 = calcularMedia(respuestas1);
  double mediaRespuesta2 = calcularMedia(respuestas2);
  double mediaRespuesta3 = calcularMedia(respuestas3);
  double mediaRespuesta4 = calcularMedia(respuestas4);
  double mediaRespuesta5 = calcularMedia(respuestas5);

  // Guardar las medias en un documento llamado "Media" dentro de la colección de Lengua
  final mediaDocRef = FirebaseFirestore.instance
      .collection('profesores')
      .doc(profesorId)
      .collection('Asignaturas')
      .doc('Lengua')
      .collection(trimestre)
      .doc('Media');

  await mediaDocRef.set({
    'media_respuesta_1': mediaRespuesta1,
    'media_respuesta_2': mediaRespuesta2,
    'media_respuesta_3': mediaRespuesta3,
    'media_respuesta_4': mediaRespuesta4,
    'media_respuesta_5': mediaRespuesta5,
  });
}

// Función para calcular la media de una lista de números enteros
double calcularMedia(List<int> lista) {
  if (lista.isEmpty) return 0;
  return lista.reduce((a, b) => a + b) / lista.length;
}
