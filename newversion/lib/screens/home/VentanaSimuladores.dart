import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';

class VentanaSimuladores extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simuladores de Inversión'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prueba tus estrategias de inversión con dinero ficticio.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildSimuladorCard('Acciones', FontAwesomeIcons.chartLine, Colors.blue),
                  _buildSimuladorCard('Criptomonedas', FontAwesomeIcons.coins, Colors.orange),
                  _buildSimuladorCard('Forex', FontAwesomeIcons.dollarSign, Colors.purple),
                  _buildSimuladorCard('Commodities', FontAwesomeIcons.boxOpen, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimuladorCard(String title, IconData icon, Color color) {
    return OpenContainer(
      closedColor: Colors.white,
      openColor: Colors.white,
      closedElevation: 5,
      openElevation: 0,
      transitionDuration: Duration(milliseconds: 500),
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      openBuilder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('Simulador de $title', style: TextStyle(fontSize: 24))),
      ),
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
