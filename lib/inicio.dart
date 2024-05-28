import 'package:flutter/material.dart';
import 'seleccion_profesor.dart';

class Inicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SeleccionProfesor(profesor: 'Profesor Nombre'),
              ),
            );
          },
          child: const Text('Seleccionar Profesor'),
        ),
      ),
    );
  }
}