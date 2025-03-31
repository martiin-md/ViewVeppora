import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newversion/screens/VentanaInicioSesionLogin.dart'; // Importa la pantalla de inicio de sesión

class VentanaRegistroConEmail extends StatefulWidget {
  const VentanaRegistroConEmail({Key? key}) : super(key: key);

  @override
  _VentanaRegistroConEmailState createState() => _VentanaRegistroConEmailState();
}

class _VentanaRegistroConEmailState extends State<VentanaRegistroConEmail> {
  // Controladores de texto para los campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Función para registrar al usuario con correo y contraseña
  Future<void> _registerWithEmail(BuildContext context) async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, completa todos los campos')),
        );
        return;
      }

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
        );
        return;
      }

      // Registrar al usuario con Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Registro exitoso');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro exitoso. ¡Bienvenido!')),
      );

      // Navegar a la pantalla de inicio de sesión después del registro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VentanaInicioSesionLogin(),
        ),
      );
    } catch (e) {
      print('Error al registrar: $e'); // Imprime el error completo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

            // Campo de correo electrónico
            TextField(
              controller: _emailController, // Conecta el controlador
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Campo de contraseña
            TextField(
              controller: _passwordController, // Conecta el controlador
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Campo de confirmación de contraseña
            TextField(
              controller: _confirmPasswordController, // Conecta el controlador
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Repite Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Botón Confirmar
            ElevatedButton(
              onPressed: () => _registerWithEmail(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirmar'),
            ),

            const SizedBox(height: 20),

            // Enlace para volver al inicio de sesión
            Center(
              child: GestureDetector(
                onTap: () {
                  // Navegar de vuelta a la pantalla de inicio de sesión
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

  @override
  void dispose() {
    // Libera los recursos cuando el widget se destruye
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}