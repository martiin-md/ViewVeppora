import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:newversion/screens/home/simuladores/acciones_simulador.dart';
import 'package:newversion/screens/home/simuladores/commodities_simulador.dart';
import 'package:newversion/screens/home/simuladores/criptos_simulador.dart';
import 'package:newversion/screens/home/simuladores/forex_simulador.dart';

class VentanaSimuladores extends StatelessWidget {
  const VentanaSimuladores({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simuladores de Inversión',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white // Blanco en modo oscuro
                : Colors.black, // Negro en modo claro
          ),
        ),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black // Fondo oscuro en modo oscuro
          : Colors.grey[200], // Fondo claro en modo claro
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prueba tus estrategias de inversión con dinero ficticio.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Blanco en modo oscuro
                    : Colors.black, // Negro en modo claro
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildSimuladorCard(
                    'Acciones',
                    FontAwesomeIcons.chartLine,
                    Colors.blue,
                    acciones_simulador(),
                  ),
                  _buildSimuladorCard(
                    'Criptomonedas',
                    FontAwesomeIcons.coins,
                    Colors.orange,
                    criptos_simulador(),
                  ),
                  _buildSimuladorCard(
                    'Forex',
                    FontAwesomeIcons.dollarSign,
                    Colors.purple,
                    forex_simulador(),
                  ),
                  _buildSimuladorCard(
                    'Commodities',
                    FontAwesomeIcons.boxOpen,
                    Colors.red,
                    commodities_simulador(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimuladorCard(
      String title, IconData icon, Color color, Widget simuladorWidget) {
    return OpenContainer(
      closedColor: Colors.white,
      openColor: Colors.white,
      closedElevation: 5,
      openElevation: 0,
      transitionDuration: Duration(milliseconds: 500),
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      openBuilder: (context, _) => simuladorWidget,
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                        ? Colors.white // Blanco en modo oscuro
                        : Colors.black, // Negro en modo claro
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
