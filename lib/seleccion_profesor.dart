import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seleccion_trimestre.dart';
import 'firebase_service.dart';

class SeleccionProfesor extends StatelessWidget {
  final String profesorId;

  const SeleccionProfesor({Key? key, required this.profesorId}) : super(key: key);

  Future<List<String>> _getAsignaturas() async {
    return await getAsignaturas(profesorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccione una asignatura'),
      ),
      body: FutureBuilder<List<String>>(
        future: _getAsignaturas(),
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
                  title: Text(asignatura),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeleccionTrimestre(profesorId: profesorId, asignatura: asignatura),
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