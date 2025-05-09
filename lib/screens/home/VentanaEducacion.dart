import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para obtener UID

import 'educacion/DetalleCurso.dart';

class VentanaEducacion extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final String? uid = auth.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        body: Center(child: Text("Usuario no autenticado")),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('usuarios').doc(uid).get(),
      builder: (context, snapshotUsuario) {
        if (!snapshotUsuario.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        int progresoCurso = snapshotUsuario.data!.get('progresoCurso') ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Educación Interactiva',
              style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color), // Color dinámico
            ),
            backgroundColor: Theme.of(context).primaryColor, // Color dinámico
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Fondo dinámico
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aprende sobre Finanzas de manera divertida y efectiva.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Texto blanco en modo oscuro
                        : Colors.black, // Texto negro en modo claro
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection('cursos').snapshots(),
                    builder: (context, snapshotCursos) {
                      if (!snapshotCursos.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final cursos = snapshotCursos.data!.docs;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: cursos.length,
                        itemBuilder: (context, index) {
                          final cursoDoc = cursos[index];
                          final data = cursoDoc.data() as Map<String, dynamic>;

                          int nivelCurso = data['nivel'] ?? 0;
                          bool desbloqueado = nivelCurso <= progresoCurso;

                          return _buildEducationCard(
                            context,
                            data['nombre'] ?? 'Curso',
                            FontAwesomeIcons.bookOpen,
                            desbloqueado ? Colors.green : Colors.white,
                            cursoDoc.id,
                            desbloqueado,
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
      },
    );
  }

  Widget _buildEducationCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      String cursoId,
      bool desbloqueado,
      ) {
    return OpenContainer(
      closedColor: Theme.of(context).cardColor, // Color dinámico para el fondo de la tarjeta
      openColor: Theme.of(context).cardColor, // Color dinámico
      closedElevation: 5,
      openElevation: 0,
      transitionDuration: Duration(milliseconds: 500),
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      openBuilder: (context, _) => desbloqueado
          ? DetalleCurso(cursoId: cursoId)
          : Scaffold(
        appBar: AppBar(title: Text("Curso Bloqueado")),
        body: Center(child: Text("Completa el nivel anterior para desbloquear este curso.")),
      ),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Opacity(
          opacity: desbloqueado ? 1.0 : 0.5,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(icon, color: color, size: 40),
                  SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white // Texto blanco en modo oscuro
                          : Colors.black, // Texto negro en modo claro
                    ),
                  ),
                  if (!desbloqueado)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.lock, color: Colors.redAccent),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
