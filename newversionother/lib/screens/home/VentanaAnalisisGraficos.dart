import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import 'package:newversion/screens/home/analisis/acciones_analisis.dart';
import 'package:newversion/screens/home/analisis/commodities_analisis.dart';
import 'package:newversion/screens/home/analisis/cripto_analisis.dart';
import 'package:newversion/screens/home/analisis/forex_analisis.dart';


class VentanaAnalisisGraficos extends StatelessWidget {
  const VentanaAnalisisGraficos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis del Mercado'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explora gráficos y datos en tiempo real.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildAnalisisCard('Acciones', FontAwesomeIcons.chartLine, Colors.blue, acciones_analisis()),
                  _buildAnalisisCard('Criptomonedas', FontAwesomeIcons.coins, Colors.orange, cripto_analisis()),
                  _buildAnalisisCard('Forex', FontAwesomeIcons.dollarSign, Colors.purple, forex_analisis()),
                  _buildAnalisisCard('Commodities', FontAwesomeIcons.boxOpen, Colors.red, commodities_analisis()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalisisCard(String title, IconData icon, Color color, Widget analysisPage) {
    return OpenContainer(
      closedColor: Colors.white,
      openColor: Colors.white,
      closedElevation: 5,
      openElevation: 0,
      transitionDuration: Duration(milliseconds: 500),
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      openBuilder: (context, _) => analysisPage, // Aquí asignas la ventana correspondiente
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
