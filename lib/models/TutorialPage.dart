import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  final VoidCallback onCompleted;

  const TutorialPage({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido a la app')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¡Bienvenido a nuestra app! Te vamos a guiar brevemente.'),
            SizedBox(height: 20),
            Text('Aquí va el tutorial sobre la app y sus características principales.'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: onCompleted,
              child: Text('¡Comenzar!'),
            ),
          ],
        ),
      ),
    );
  }
}
