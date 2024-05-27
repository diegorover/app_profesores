import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seleccion_trimestre.dart';

class SeleccionProfesor extends StatelessWidget {
  final String asignatura;

  const SeleccionProfesor({Key? key, required this.asignatura}) : super(key: key);

  Future<List<String>> getProfesores() async {
    // El ID del documento es fijo: '4kReqVo85w4yVWcviLGB'
    final docRef = FirebaseFirestore.instance.collection('profesores').doc('4kReqVo85w4yVWcviLGB');
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['Asignatura'] == asignatura) {
        if (data.containsKey('Profesor')) {
          List<String> profesores = List<String>.from(data['Profesor']);
          return profesores;
        }
      }
    }
    throw Exception('La asignatura no existe en la base de datos.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccione un profesor de $asignatura'),
      ),
      body: FutureBuilder<List<String>>(
        future: getProfesores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay profesores disponibles.'));
          } else {
            final profesores = snapshot.data!;
            return ListView.builder(
              itemCount: profesores.length,
              itemBuilder: (context, index) {
                final profesor = profesores[index];
                return ListTile(
                  title: Text(profesor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeleccionTrimestre(asignatura: asignatura, profesor: profesor),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

