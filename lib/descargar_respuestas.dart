import 'dart:io' as io; // Para verificar la plataforma
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DescargarRespuestas extends StatefulWidget {
  final String profesor;
  final int trimestre;

  const DescargarRespuestas({Key? key, required this.profesor, required this.trimestre}) : super(key: key);

  @override
  _DescargarRespuestasState createState() => _DescargarRespuestasState();
}

class _DescargarRespuestasState extends State<DescargarRespuestas> {
  Future<Map<String, dynamic>> getRespuestas() async {
    final docRef = FirebaseFirestore.instance.collection('profesores').doc('4kReqVo85w4yVWcviLGB');
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        final fieldName = 'Respuestas Trimestre ${widget.trimestre} ${widget.profesor}';
        if (data.containsKey(fieldName)) {
          return Map<String, dynamic>.from(data[fieldName]);
        }
      }
    }
    return {};
  }

  Future<void> _downloadJson() async {
    print('Intentando descargar JSON...');
    final respuestas = await getRespuestas();
    print('Respuestas obtenidas: $respuestas');
    if (respuestas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay respuestas disponibles para descargar.')),
      );
      return;
    }

    final fileName = 'Respuestas_Trimestre_${widget.trimestre}_${widget.profesor}.json';

    if (kIsWeb) {
      print('Estamos en la plataforma web.');
      final jsonString = jsonEncode(respuestas);
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      print('Estamos en una plataforma no web.');
      final directory = await getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/$fileName');
      await file.writeAsString(jsonEncode(respuestas));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Respuestas descargadas en ${file.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descargar respuestas - ${widget.profesor}'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _downloadJson,
          child: const Text('Descargar Respuestas'),
        ),
      ),
    );

  }
}
