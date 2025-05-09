import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newversion/models/quiz_page.dart';
import 'package:newversion/models/test_page.dart';
import 'package:newversion/models/inversiongame_page.dart';
import 'ContenidoCompleto.dart';

class DetalleCurso extends StatelessWidget {
  final String cursoId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DetalleCurso({required this.cursoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Curso'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('cursos').doc(cursoId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final nombreCurso = data['nombre'] ?? "Sin título";
          final descripcionCurso = data['descripcion'] ?? "Sin descripción";
          final nivelCurso = data['nivel'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreCurso,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.deepOrange, // Cambiar color según tema
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  descripcionCurso,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70  // Texto gris claro en modo oscuro
                        : Colors.grey[700],  // Gris oscuro en modo claro
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: firestore.collection('cursos').doc(cursoId).collection('modulos').orderBy('orden').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                    final modulos = snapshot.data!.docs;
                    return Column(
                      children: [
                        ...modulos.map((moduloDoc) {
                          final moduloData = moduloDoc.data() as Map<String, dynamic>;
                          final moduloNombre = moduloData['nombre'] ?? "Módulo sin nombre";

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Theme(
                              data: ThemeData(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                leading: Icon(Icons.menu_book, color: Colors.deepOrange),
                                title: Text(
                                  moduloNombre,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white // Texto blanco en modo oscuro
                                        : Colors.deepOrange, // Texto naranja en modo claro
                                  ),
                                ),
                                childrenPadding: EdgeInsets.all(15),
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: firestore
                                        .collection('cursos')
                                        .doc(cursoId)
                                        .collection('modulos')
                                        .doc(moduloDoc.id)
                                        .collection('lecciones')
                                        .orderBy('orden')
                                        .snapshots(),
                                    builder: (context, leccionesSnapshot) {
                                      if (!leccionesSnapshot.hasData) return Center(child: CircularProgressIndicator());

                                      final lecciones = leccionesSnapshot.data!.docs;
                                      return Column(
                                        children: lecciones.map((leccionDoc) {
                                          final leccionData = leccionDoc.data() as Map<String, dynamic>;
                                          final leccionNombre = leccionData['nombre'] ?? "Lección sin nombre";
                                          final leccionDescripcion = leccionData['descripcion'] ?? "Sin descripción";
                                          final leccionContenido = leccionData['contenido'] ?? "";
                                          final tipo = leccionData['tipo'] ?? 'contenido';

                                          return ListTile(
                                            onTap: () {
                                              if (tipo == 'quiz') {
                                                final preguntas = List<Map<String, dynamic>>.from(leccionData['preguntas'] ?? []);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => QuizPage(
                                                      titulo: leccionNombre,
                                                      preguntas: preguntas,
                                                    ),
                                                  ),
                                                );
                                              } else if (tipo == 'test') {
                                                final preguntas = List<Map<String, dynamic>>.from(leccionData['preguntas'] ?? []);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TestPage(
                                                      titulo: leccionNombre,
                                                      preguntas: preguntas,
                                                    ),
                                                  ),
                                                );
                                              } else if (tipo == 'minijuego') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => InversionGamePage()),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ContenidoCompleto(
                                                      titulo: leccionNombre,
                                                      descripcion: leccionDescripcion,
                                                      contenido: leccionContenido,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            leading: Icon(Icons.article, color: Colors.deepOrange),
                                            title: Text(
                                              leccionNombre,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.white // Blanco en modo oscuro
                                                    : Colors.grey, // Negro en modo claro
                                              ),
                                            ),
                                            subtitle: Text(
                                              leccionDescripcion,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.openSans(
                                                fontSize: 14,
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.white70 // Gris claro en modo oscuro
                                                    : Colors.grey[700], // Gris oscuro en modo claro
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                        SizedBox(height: 30),
                        Center(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.check_circle_outline, color: Colors.white),
                            label: Text(
                              "Marcar como completado",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              final currentUser = FirebaseAuth.instance.currentUser;
                              if (currentUser != null) {
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('usuarios')
                                    .doc(currentUser.uid)
                                    .get();
                                final progresoCurso = userDoc.data()?['progresoCurso'] ?? 0;

                                if (nivelCurso >= progresoCurso) {
                                  await FirebaseFirestore.instance
                                      .collection('usuarios')
                                      .doc(currentUser.uid)
                                      .update({'progresoCurso': nivelCurso + 1});

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('¡Curso completado! Se ha desbloqueado el siguiente nivel.')),
                                  );

                                  Navigator.pop(context); // Volver atrás
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Este curso ya estaba completado.')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
