import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seleccion_trimestre.dart';

class SeleccionProfesor extends StatelessWidget {
  final String profesor;

  const SeleccionProfesor({Key? key, required this.profesor}) : super(key: key);

  Future<List<Map<String, String>>> getAsignaturas(String profesorId) async {
    List<Map<String, String>> asignaturas = [];
    final asignaturasCollection = FirebaseFirestore.instance
        .collection('profesores')
        .doc(profesorId)
        .collection('Asignaturas');

    final snapshot = await asignaturasCollection.get();

    for (var doc in snapshot.docs) {
      final nombre = doc.data()['nombre'] as String;
      asignaturas.add({'id': doc.id, 'nombre': nombre});
    }

    return asignaturas;
  }

  Future<String?> getProfesorId(String profesorNombre) async {
    final profesoresCollection = FirebaseFirestore.instance.collection('profesores');
    final querySnapshot = await profesoresCollection.get();

    for (var doc in querySnapshot.docs) {
      final datosProfesor = await doc.reference
          .collection('Datos del Profesor')
          .doc('V2z4VP9vewIe4Jwrd5BG')
          .get();

      if (datosProfesor.exists &&
          datosProfesor.data() != null &&
          datosProfesor.data()!['Nombre'] == profesorNombre) {
        return doc.id;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccione una asignatura de $profesor'),
      ),
      body: FutureBuilder<String?>(
        future: getProfesorId(profesor),
        builder: (context, profesorSnapshot) {
          if (profesorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (profesorSnapshot.hasError) {
            return Center(child: Text('Error: ${profesorSnapshot.error}'));
          } else if (!profesorSnapshot.hasData || profesorSnapshot.data == null) {
            return const Center(child: Text('No se encontró el profesor.'));
          } else {
            final profesorId = profesorSnapshot.data!;
            return FutureBuilder<List<Map<String, String>>>(
              future: getAsignaturas(profesorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay asignaturas disponibles.'));
                } else {
                  final asignaturas = snapshot.data!;
                  return ListView.builder(
                    itemCount: asignaturas.length,
                    itemBuilder: (context, index) {
                      final asignatura = asignaturas[index];
                      return ListTile(
                        title: Text(asignatura['nombre']!),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SeleccionTrimestre(asignatura: asignatura['nombre']!, profesor: profesorId),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}



