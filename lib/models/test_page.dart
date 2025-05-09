import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newversion/models/resultado_service.dart';

class TestPage extends StatefulWidget {
  final String titulo;
  final List<Map<String, dynamic>> preguntas;

  TestPage({required this.titulo, required this.preguntas});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<int?> _respuestas = [];

  @override
  void initState() {
    super.initState();
    _respuestas = List.filled(widget.preguntas.length, null);
  }

  void _enviarTest() async {
    int correctas = 0;
    for (int i = 0; i < widget.preguntas.length; i++) {
      if (_respuestas[i] == widget.preguntas[i]['respuestaCorrecta']) {
        correctas++;
      }
    }

    final monedasGanadas = correctas * 10;
    await ResultadoService.guardarPuntos(correctas);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Resultado del Test', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Obtuviste $correctas de ${widget.preguntas.length} respuestas correctas.',
              style: GoogleFonts.openSans(),
            ),
            SizedBox(height: 10),
            Text(
              'Ganaste $monedasGanadas monedas ficticias 💰',
              style: GoogleFonts.openSans(color: Colors.green[800]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text('Finalizar', style: TextStyle(color: Colors.deepOrangeAccent)),
          ),
        ],
      ),
    );
  }


  Widget _buildPregunta(int index) {
    final pregunta = widget.preguntas[index];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pregunta ${index + 1}: ${pregunta['pregunta']}', style: GoogleFonts.poppins(fontSize: 16)),
            ...List.generate(
              pregunta['opciones'].length,
                  (i) => RadioListTile<int>(
                title: Text(pregunta['opciones'][i], style: GoogleFonts.openSans()),
                value: i,
                groupValue: _respuestas[index],
                onChanged: (value) {
                  setState(() {
                    _respuestas[index] = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.preguntas.length,
                itemBuilder: (_, index) => _buildPregunta(index),
              ),
            ),
            ElevatedButton(
              onPressed: _respuestas.contains(null)
                  ? null
                  : _enviarTest,
              child: Text('Enviar Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
