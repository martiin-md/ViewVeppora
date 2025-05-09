import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NivelPage extends StatelessWidget {
  final String nivelId;
  final String titulo;

  const NivelPage({required this.nivelId, required this.titulo});

  @override
  Widget build(BuildContext context) {
    final nivelRef = FirebaseFirestore.instance.collection('educacion').doc(nivelId);

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: nivelRef.collection('lecciones').orderBy('orden').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final lecciones = snapshot.data!.docs;

          if (lecciones.isEmpty) {
            return Center(child: Text('No hay lecciones aún.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: lecciones.length,
            itemBuilder: (context, index) {
              final leccion = lecciones[index];
              final titulo = leccion['titulo'] ?? 'Sin título';
              final contenido = leccion['contenido'] ?? '';
              final tipo = leccion['tipo'] ?? 'texto';

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(contenido),
                      SizedBox(height: 10),
                      Text('Tipo: $tipo', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
