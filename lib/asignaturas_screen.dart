import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AsignaturasScreen extends StatelessWidget {
  final String profesorId;

  const AsignaturasScreen({Key? key, required this.profesorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asignaturas'),
      ),
      body: AsignaturasList(profesorId: profesorId),
    );
  }
}

class AsignaturasList extends StatelessWidget {
  final String profesorId;

  const AsignaturasList({Key? key, required this.profesorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('profesores').doc(profesorId).collection('Asignaturas').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay asignaturas disponibles.'));
        } else {
          final asignaturas = snapshot.data!.docs.map((doc) => doc['Asignatura']).toList();
          return ListView.builder(
            itemCount: asignaturas.length,
            itemBuilder: (context, index) {
              final asignatura = asignaturas[index];
              return ListTile(
                title: Text(asignatura),
              );
            },
          );
        }
      },
    );
  }
}
