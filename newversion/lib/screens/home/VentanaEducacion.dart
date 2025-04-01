import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';

class VentanaEducacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Educación Interactiva'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aprende sobre Finanzas de manera divertida y efectiva.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildEducationCard('Principiante', FontAwesomeIcons.bookOpen, Colors.green),
                  _buildEducationCard('Intermedio', FontAwesomeIcons.graduationCap, Colors.blue),
                  _buildEducationCard('Avanzado', FontAwesomeIcons.brain, Colors.red),
                  _buildEducationCard('Desafíos', FontAwesomeIcons.trophy, Colors.amber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(String title, IconData icon, Color color) {
    return OpenContainer(
      closedColor: Colors.white,
      openColor: Colors.white,
      closedElevation: 5,
      openElevation: 0,
      transitionDuration: Duration(milliseconds: 500),
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      openBuilder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('Contenido de $title', style: TextStyle(fontSize: 24))),
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
