import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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

  List<String> preguntas = [];
  List<String> preguntasNum = [];

  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    if (data != null) {
      if (data.containsKey('Preguntas')) {
        preguntas = List<String>.from(data['Preguntas']);
      }
      TextInputType.number;
      if (data.containsKey('PreguntasNum')) {
        preguntasNum = List<String>.from(data['PreguntasNum']);
      }
    }
  }

  // Limitar a 5 preguntas
  preguntas = preguntas.length > 5 ? preguntas.sublist(0, 5) : preguntas;
  preguntasNum = preguntasNum.length > 5 ? preguntasNum.sublist(0, 5) : preguntasNum;

  // Combinamos ambos tipos de preguntas
  return [...preguntas, ...preguntasNum];
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

