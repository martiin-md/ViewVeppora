import 'package:animations/animations.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bienvenido, Usuario!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue, // Fondo de color personalizado
                    radius: 25,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VentanaPerfil()),
                        );
                      },
                      child: FaIcon(
                        FontAwesomeIcons.user, // Ícono de cuenta de perfil
                        size: 25.0, // Tamaño del ícono
                        color: Colors.white, // Color del ícono
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Tu progreso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(value: 0.6, color: Colors.blue, backgroundColor: Colors.grey[300]),
              SizedBox(height: 30),
              Text(
                'Secciones principales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildAnimatedCard(
                      context,
                      'Educación Interactiva',
                      FontAwesomeIcons.bookOpen,
                      Colors.orange,
                      VentanaEducacion(),
                    ),
                    _buildAnimatedCard(
                      context,
                      'Simuladores',
                      FontAwesomeIcons.chartLine,
                      Colors.green,
                      VentanaSimuladores(),
                    ),
                    _buildAnimatedCard(
                      context,
                      'Análisis de Mercado',
                      FontAwesomeIcons.chartPie,
                      Colors.purple,
                      VentanaAnalisisGraficos(),
                    ),
                    _buildAnimatedCard(context, 'Billetera',
                        FontAwesomeIcons.wallet,
                        Colors.brown,
                        VentanaBilletera(userId: '',)
                    ),
                    _buildAnimatedCard(context,
                        'Noticias',
                        FontAwesomeIcons.newspaper,
                        Colors.red,
                        VentanaNoticias()
                    ),
                    _buildAnimatedCard(context,
                        'Suscripciones',
                        FontAwesomeIcons.shopify,
                        Colors.yellow,
                        VentanaSuscripcion()
                    )
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
      closedColor: Colors.white,
      openColor: Colors.white,
      closedElevation: 5,
      openElevation: 0,
      transitionDuration: Duration(milliseconds: 500),
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      openBuilder: (context, _) => nextPage,
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}