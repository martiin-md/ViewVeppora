import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeccionContenido extends StatelessWidget {
  final String titulo;

  const SeccionContenido({super.key, required this.titulo});

  Future<String> obtenerContenido() async {
    final doc = await FirebaseFirestore.instance.collection('secciones').doc(titulo).get();
    return doc.data()?['contenido'] ?? 'Contenido no disponible.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: FutureBuilder<String>(
        future: obtenerContenido(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar contenido.'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                snapshot.data ?? 'Sin contenido',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}
