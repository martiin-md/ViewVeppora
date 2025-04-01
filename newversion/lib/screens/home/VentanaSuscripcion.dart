import 'package:flutter/material.dart';

class VentanaSuscripcion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suscripciones'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige tu Plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            subscriptionCard('Free', 'Acceso limitado a cursos y simuladores.', Icons.lock_open, Colors.green, context),
            SizedBox(height: 20),
            subscriptionCard('Premium', 'Acceso completo con funcionalidades avanzadas.', Icons.star, Colors.amber, context),
          ],
        ),
      ),
    );
  }

  Widget subscriptionCard(String title, String description, IconData icon, Color iconColor, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Aquí iría la lógica para seleccionar el plan
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: iconColor),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(description),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
