import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VentanaRecuperarContrasena extends StatefulWidget {
  const VentanaRecuperarContrasena({super.key});

  @override
  State<VentanaRecuperarContrasena> createState() => _VentanaRecuperarContrasenaState();
}

class _VentanaRecuperarContrasenaState extends State<VentanaRecuperarContrasena> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _recuperarContrasena() async {
    final email = _emailController.text.trim();
    print('Correo ingresado: $email'); // Log de depuración

    if (email.isEmpty || !email.contains('@')) {
      print('Correo no válido'); // Log si el correo es inválido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, introduce un correo válido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Intentando enviar el correo de recuperación...'); // Log antes de la llamada a Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se envió un correo de recuperación a $email')),
      );
      print('Correo enviado con éxito'); // Log si se envía el correo
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Ocurrió un error. Inténtalo más tarde.';
      if (e.code == 'user-not-found') {
        mensaje = 'No se encontró una cuenta con ese correo.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
      print('Error de Firebase: ${e.message}'); // Log de error de Firebase
    } catch (e) {
      print('Error desconocido: $e'); // Log para cualquier otro tipo de error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 20),
            const Text(
              'ViewVeppora',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Encuentra tu cuenta',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Checkbox(value: true, onChanged: null), // Checkbox simulado
                Text('No soy un robot'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _recuperarContrasena,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enviar correo de recuperación'),
            ),
          ],
        ),
      ),
    );
  }
}
