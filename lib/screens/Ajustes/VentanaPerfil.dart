import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'VentanaAjustes.dart';

class VentanaPerfil extends StatefulWidget {
  const VentanaPerfil({super.key});

  @override
  _VentanaPerfilState createState() => _VentanaPerfilState();
}

class _VentanaPerfilState extends State<VentanaPerfil> {
  final user = FirebaseAuth.instance.currentUser;

  void _actualizarNombre() async {
    final nuevoNombre = await _mostrarDialogoTexto('Nuevo nombre');
    if (nuevoNombre != null && nuevoNombre.isNotEmpty) {
      await user!.updateDisplayName(nuevoNombre);
      await user!.reload();
      setState(() {});
    }
  }

  void _actualizarCorreo() async {
    final nuevoCorreo = await _mostrarDialogoTexto('Nuevo correo');
    if (nuevoCorreo != null && nuevoCorreo.isNotEmpty) {
      try {
        await user!.updateEmail(nuevoCorreo);
        await user!.reload();
        setState(() {});
      } catch (e) {
        _mostrarError('Error al actualizar el correo: $e');
      }
    }
  }

  Future<void> _actualizarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      try {
        // Subir imagen a Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('fotos_perfil')
            .child('${user!.uid}.jpg');

        await storageRef.putFile(file);

        final url = await storageRef.getDownloadURL();

        // Actualizar foto en perfil de usuario
        await user!.updatePhotoURL(url);
        await user!.reload();
        setState(() {});
      } catch (e) {
        _mostrarError('Error al subir la imagen: $e');
      }
    } else {
      _mostrarMensaje('No se seleccionó ninguna imagen');
    }
  }

  void _cambiarContrasena() async {
    final nuevaContrasena = await _mostrarDialogoTexto('Nueva contraseña');
    if (nuevaContrasena != null && nuevaContrasena.length >= 6) {
      try {
        await user!.updatePassword(nuevaContrasena);
        _mostrarMensaje('Contraseña actualizada correctamente');
      } catch (e) {
        _mostrarError('Error al cambiar la contraseña: $e');
      }
    } else {
      _mostrarError('La contraseña debe tener al menos 6 caracteres');
    }
  }

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/'); // o al login
  }

  Future<String?> _mostrarDialogoTexto(String titulo) async {
    String valor = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          autofocus: true,
          onChanged: (value) => valor = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, valor), child: Text('Guardar')),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.red,
    ));
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Sin nombre';
    final email = user?.email ?? 'Sin correo';
    final photoURL = user?.photoURL ?? 'https://www.w3schools.com/howto/img_avatar.png';

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
        backgroundColor: Theme.of(context).primaryColor, // Usar el color del tema
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Fondo dinámico
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _actualizarFoto,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(photoURL),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor), // Color dinámico
                  onPressed: _actualizarNombre,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Correo: $email',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor), // Color dinámico
                  onPressed: _actualizarCorreo,
                ),
              ],
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).iconTheme.color), // Icono dinámico
              title: Text('Configuraciones'),
              trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).iconTheme.color), // Icono dinámico
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VentanaAjustes(onThemeToggle: () {})), // Implementa la función callback en tu código principal
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.lock, color: Theme.of(context).iconTheme.color), // Icono dinámico
              title: Text('Cambiar Contraseña'),
              trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).iconTheme.color), // Icono dinámico
              onTap: _cambiarContrasena,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red), // Color rojo para cerrar sesión
              title: Text('Cerrar Sesión'),
              trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).iconTheme.color), // Icono dinámico
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }
}
