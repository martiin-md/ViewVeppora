import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContenidoCompleto extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String contenido;

  ContenidoCompleto({
    required this.titulo,
    required this.descripcion,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              titulo,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Blanco en modo oscuro
                    : Colors.deepOrangeAccent, // Naranja en modo claro
              ),
            ),
            SizedBox(height: 10),

            // Descripción
            Text(
              descripcion,
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70 // Gris claro en modo oscuro
                    : Colors.grey[700], // Gris oscuro en modo claro
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),

            // Contenido Completo
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  contenido,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Blanco en modo oscuro
                        : Colors.black87, // Gris oscuro en modo claro
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
