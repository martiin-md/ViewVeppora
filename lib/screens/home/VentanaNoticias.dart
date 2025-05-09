import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newversion/models/detalles_noticias.dart';

import '../../services/Servicio_Firestore.dart';

class VentanaNoticias extends StatelessWidget {
  const VentanaNoticias({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Noticias Financieras',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white // Blanco en modo oscuro
                : Colors.black, // Negro en modo claro
          ),
        ),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black // Fondo oscuro en modo oscuro
          : Colors.grey[100], // Fondo claro en modo claro
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Últimas Noticias & Consejos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Blanco en modo oscuro
                    : Colors.black, // Negro en modo claro
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirestoreService().getNoticias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar noticias'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No hay noticias disponibles'));
                  }

                  final noticias = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: noticias.length,
                    itemBuilder: (context, index) {
                      final noticia = noticias[index];
                      final data = noticia.data() as Map<String, dynamic>;

                      final titulo = data['titulo'] ?? 'Sin título';
                      final descripcion = data['descripcion'] ?? 'Sin descripción';
                      final fecha = data['fecha'] != null
                          ? (data['fecha'] as Timestamp).toDate()
                          : null;
                      final imagenUrl = data['imagenUrl'];

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800] // Fondo oscuro para las cards en modo oscuro
                            : Colors.white, // Fondo claro para las cards en modo claro
                        child: ListTile(
                          leading: imagenUrl != null && imagenUrl != ""
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imagenUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Icon(Icons.article, size: 40, color: Colors.grey),
                          title: Text(
                            titulo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white // Blanco en modo oscuro
                                  : Colors.black, // Negro en modo claro
                            ),
                          ),
                          subtitle: Text(
                            '$descripcion${fecha != null ? '\n${fecha.toLocal().toString().split(" ")[0]}' : ''}',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70 // Blanco opaco en modo oscuro
                                  : Colors.black87, // Negro más suave en modo claro
                            ),
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetallesNoticias(docId: noticia.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
