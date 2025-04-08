import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newversion/screens/Logins/VentanaInicioSesionLogin.dart';
import 'package:newversion/screens/Logins/VentanaRegistroConEmail.dart';

class VentanaRegistroLogin extends StatelessWidget {
  const VentanaRegistroLogin({Key? key}) : super(key: key);

  /// Función para registrar al usuario con Google
  Future<void> _registerWithGoogle(BuildContext context) async {
    try {
      print('Iniciando sesión con Google...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('El usuario canceló el inicio de sesión.');
        return;
      }

      print('Obteniendo credenciales de autenticación...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Creando credencial de Firebase...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Iniciando sesión en Firebase...');
      await FirebaseAuth.instance.signInWithCredential(credential);

      print('Registro con Google exitoso');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro con Google exitoso')),
      );

      // Navegar a la pantalla principal después del registro
      Navigator.pushReplacementNamed(context, '/home'); // Asegúrate de tener definida la ruta '/home'
    } catch (e) {
      print('Error al registrar con Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Función para navegar a la pantalla de registro con correo electrónico
  Future<void> _registerWithEmail(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VentanaRegistroConEmail(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Image.asset('assets/logo.png', height: 100),
            ),
            const SizedBox(height: 30),

            // Botón "Registrarse con Apple"
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registro con Apple no implementado')),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.apple, color: Colors.black),
              label: const Text('Registrarse con Apple'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: screenWidth * 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),

            // Separador con texto
            Row(children: const [
              Expanded(child: Divider()),
              Text('  O Registrar con  '),
              Expanded(child: Divider()),
            ]),
            const SizedBox(height: 15),

            // Botón "Registrarse con Google"
            ElevatedButton.icon(
              onPressed: () => _registerWithGoogle(context), // Conectado a la función
              icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
              label: const Text('Google'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: screenWidth * 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),

            // Botón "Registrarse con Email"
            ElevatedButton.icon(
              onPressed: () => _registerWithEmail(context), // Conectado a la función
              icon: const FaIcon(FontAwesomeIcons.envelope, color: Colors.blueAccent),
              label: const Text('Email'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: screenWidth * 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            // Términos y condiciones
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                children: [
                  const TextSpan(text: 'Al registrarse, acepta nuestros '),
                  TextSpan(
                    text: 'Términos de Uso',
                    style: const TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navegar a la pantalla de términos y condiciones
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Términos de Uso no implementados')),
                        );
                      },
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: const TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navegar a la pantalla de política de privacidad
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Política de Privacidad no implementada')),
                        );
                      },
                  ),
                  const TextSpan(text: ' y '),
                  TextSpan(
                    text: 'Política de Cookies',
                    style: const TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navegar a la pantalla de política de cookies
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Política de Cookies no implementada')),
                        );
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Enlace para iniciar sesión
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VentanaInicioSesionLogin(),
                    ),
                  );
                },
                child: const Text(
                  '¿Ya tienes una cuenta? Iniciar sesión',
                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}