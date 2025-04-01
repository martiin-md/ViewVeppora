import 'package:flutter/material.dart';

class VentanaPerfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://www.w3schools.com/howto/img_avatar.png'),
            ),
            SizedBox(height: 20),
            Text(
              'Nombre de Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Correo: usuario@correo.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.teal),
              title: Text('Configuraciones'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.teal),
              title: Text('Cambiar Contraseña'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Cerrar Sesión'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
