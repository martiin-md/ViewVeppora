import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa firebase_core
import 'package:google_fonts/google_fonts.dart';
import 'screens/Logins/VentanaRegistroLogin.dart'; // Importa tu pantalla de autenticación
import 'screens/home/VentanaPrincipalHome.dart';  // Importa tu pantalla principal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const ViewVepporApp());
}

class ViewVepporApp extends StatelessWidget {
  const ViewVepporApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ViewVeppora',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        textTheme: GoogleFonts.poppinsTextTheme(),
        brightness: Brightness.light,
      ),
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => const VentanaRegistroLogin(), // Pantalla de inicio de sesión/registro
        '/home': (context) => const VentanaPrincipalHome(), // Pantalla principal
      },
    );
  }
}