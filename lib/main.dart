import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QRData(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/alumno': (context) => AlumnoScreen(),
        '/modifyQR': (context) => ModifyQRScreen(),
        '/scan': (context) => QRViewExample(),
      },
    );
  }
}

class QRData extends ChangeNotifier {
  String _qrData = 'www.google.com';

  String get qrData => _qrData;

  void updateQRData(String newQRData) {
    _qrData = newQRData;
    notifyListeners();
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (_usernameController.text == 'Admin' && _passwordController.text == 'admin123456') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inicio de sesión exitoso')));
        Navigator.pushNamed(context, '/modifyQR');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario o contraseña incorrectos')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio de Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo.png'), // Imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Usuario'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el usuario';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la contraseña';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Iniciar Sesión'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/alumno');
                  },
                  child: Text('Soy Alumno'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlumnoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String qrData = context.watch<QRData>().qrData;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Generar y Escanear QR')),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(16),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 350.0,
                  gapless: false,
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  embeddedImage: AssetImage('assets/logo.png'),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(50, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModifyQRScreen extends StatefulWidget {
  @override
  _ModifyQRScreenState createState() => _ModifyQRScreenState();
}

class _ModifyQRScreenState extends State<ModifyQRScreen> {
  final _qrUrlController = TextEditingController();

  void _updateQR() {
    String newQRData = _qrUrlController.text;
    context.read<QRData>().updateQRData(newQRData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('URL del QR actualizada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modificar URL del QR')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _qrUrlController,
                decoration: InputDecoration(labelText: 'Nueva URL para el QR'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateQR,
                child: Text('Actualizar URL'),
              ),
              SizedBox(height: 20),
              Consumer<QRData>(
                builder: (context, qrData, child) {
                  return QrImageView(
                    data: qrData.qrData,
                    version: QrVersions.auto,
                    size: 350.0,
                    gapless: false,
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    embeddedImage: AssetImage('assets/logo.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size(50, 50),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  late QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear Código QR')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Código QR Escaneado: ${result!.code}')
                  : Text('Escanea un código QR'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null && result!.code != null) {
          controller.pauseCamera();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormScreen(url: result!.code!),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class FormScreen extends StatelessWidget {
  final String url;

  FormScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formulario')),
      body: Center(
        child: Text('URL del formulario: $url'),
      ),
    );
  }
}
