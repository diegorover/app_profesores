import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Ingresa el número 1:',
            ),
            SizedBox(height: 10),
            Container(
              width: 200,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text == '1') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfessorsPage()),
                  );
                }
              },
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profesores'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Profesores').doc('Juan').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No se encontraron datos'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null || data.isEmpty) {
            return Center(child: Text('No se encontraron datos'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              var keys = data.keys.toList();
              var key = keys[index];
              var value = data[key];
              return ListTile(
                title: Text('$key: $value'),
              );
            },
          );
        },
      ),
    );
  }
}

