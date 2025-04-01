import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VentanaNoticias extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Noticias Financieras'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Últimas Noticias & Consejos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  newsCard('Bitcoin alcanza nuevo máximo histórico', 'Criptomonedas', context),
                  newsCard('Acciones de Tesla se disparan un 10%', 'Acciones', context),
                  newsCard('Consejos para diversificar tu portafolio', 'Educación Financiera', context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget newsCard(String title, String category, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
