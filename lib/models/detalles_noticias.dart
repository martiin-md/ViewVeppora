import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetallesNoticias extends StatelessWidget {
  final String docId;

  const DetallesNoticias({super.key, required this.docId});

  Future<DocumentSnapshot> obtenerDocumento() async {
    return await FirebaseFirestore.instance.collection('noticias').doc(docId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles de la Noticia"), backgroundColor: Colors.red),
      body: FutureBuilder<DocumentSnapshot>(
        future: obtenerDocumento(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Error al cargar la noticia.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final titulo = data['titulo'] ?? 'Sin título';
          final descripcion = data['descripcion'] ?? 'Sin descripción';
          final contenido = data['contenido'] ?? 'Sin contenido';
          final imagenUrl = data['imagenUrl'];
          final fecha = data['fecha'] != null
              ? (data['fecha'] as Timestamp).toDate()
              : null;

          final fechaFormateada = fecha != null
              ? DateFormat('d MMMM yyyy').format(fecha)
              : 'Sin fecha';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagenUrl != null && imagenUrl != '')
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.network(
                      imagenUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 10),
                      Text(
                        fechaFormateada,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        descripcion,
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                      const Divider(height: 30),
                      Text(
                        contenido,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
