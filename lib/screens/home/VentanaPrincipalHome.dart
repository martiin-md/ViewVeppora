import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Ajustes/VentanaPerfil.dart';
import 'VentanaAnalisisGraficos.dart';
import 'VentanaBilletera.dart';
import 'VentanaEducacion.dart';
import 'VentanaNoticias.dart';
import 'VentanaSimuladores.dart';
import 'VentanaSuscripcion.dart';

class VentanaPrincipalHome extends StatelessWidget {
  const VentanaPrincipalHome({super.key, required VoidCallback onThemeToggle});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.email?.split('@').first ?? 'Usuario';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,  // Fondo dinámico
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hola, $userName 👋',
                    style: Theme.of(context).textTheme.headlineSmall,  // Usar el tema para el texto
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VentanaPerfil()),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,  // Usar el color primario del tema
                      radius: 26,
                      child: FaIcon(FontAwesomeIcons.user, size: 22, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Progreso del curso
              Text('Progreso del Curso', style: Theme.of(context).textTheme.titleMedium),  // Usar el tema para el texto
              const SizedBox(height: 10),

              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('usuarios').doc(user?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const LinearProgressIndicator();
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final progresoCurso = (data['progresoCurso'] ?? 0).toInt();
                  final double porcentaje = [0.0, 0.5, 1.0][progresoCurso.clamp(0, 2)];
                  final nivel = ['Principiante', 'Profesional', 'Experto'][progresoCurso.clamp(0, 2)];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nivel,
                        style: Theme.of(context).textTheme.bodyMedium,  // Usar el tema para el texto
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: porcentaje,
                          minHeight: 10,
                          backgroundColor: Theme.of(context).dividerColor,  // Color de fondo dinámico
                          color: Theme.of(context).primaryColor,  // Color dinámico
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Secciones
              Text('Explora las secciones', style: Theme.of(context).textTheme.titleMedium),  // Usar el tema para el texto
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  children: [
                    _buildAnimatedCard(context, 'Educación', FontAwesomeIcons.bookOpen, Colors.orange, VentanaEducacion()),
                    _buildAnimatedCard(context, 'Simuladores', FontAwesomeIcons.chartLine, Colors.green, const VentanaSimuladores()),
                    _buildAnimatedCard(context, 'Mercado', FontAwesomeIcons.chartPie, Colors.deepPurple, const VentanaAnalisisGraficos()),
                    _buildAnimatedCard(context, 'Billetera', FontAwesomeIcons.wallet, Colors.brown, VentanaBilletera(userId: user!.uid)),
                    _buildAnimatedCard(context, 'Noticias', FontAwesomeIcons.newspaper, Colors.red, const VentanaNoticias()),
                    _buildAnimatedCard(context, 'Suscripción', FontAwesomeIcons.shopify, Colors.indigo, VentanaSuscripcion(userId: user!.uid)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      Widget nextPage,
      ) {
    return OpenContainer(
      closedColor: Theme.of(context).cardColor,  // Usar el color de la tarjeta del tema
      openColor: Theme.of(context).cardColor,  // Usar el color de la tarjeta del tema
      closedElevation: 4,
      transitionDuration: const Duration(milliseconds: 450),
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      openBuilder: (context, _) => nextPage,
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          shadowColor: Theme.of(context).shadowColor,  // Usar el color de la sombra del tema
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: color, size: 36),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,  // Usar el texto del tema
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
