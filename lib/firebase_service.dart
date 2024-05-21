import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getProfesores() async {
  List<Map<String, dynamic>> profesores = [];
  CollectionReference collectionReferenceProfesores = db.collection('profesores');

  QuerySnapshot queryProfesores = await collectionReferenceProfesores.get();

  for (var documento in queryProfesores.docs) {
    profesores.add(documento.data() as Map<String, dynamic>);
  }

  return profesores;
}
