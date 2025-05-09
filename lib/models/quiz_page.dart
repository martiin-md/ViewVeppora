import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:newversion/models/resultado_service.dart';

class QuizPage extends StatefulWidget {
  final String titulo;
  final List<Map<String, dynamic>> preguntas;

  QuizPage({required this.titulo, required this.preguntas});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  PageController _pageController = PageController();
  List<int?> _respuestas = [];
  int _puntos = 0;

  @override
  void initState() {
    super.initState();
    _respuestas = List.filled(widget.preguntas.length, null);
  }

  void _verificarRespuesta(int preguntaIndex, int seleccion) {
    if (_respuestas[preguntaIndex] != null) return;

    setState(() {
      _respuestas[preguntaIndex] = seleccion;

      bool correcta = seleccion == widget.preguntas[preguntaIndex]['respuestaCorrecta'];
      if (correcta) _puntos++;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(correcta ? Icons.check_circle : Icons.cancel, color: Colors.white),
            SizedBox(width: 8),
            Text(correcta ? '¡Correcto!' : 'Incorrecto'),
          ],
        ),
        backgroundColor: correcta ? Colors.green : Colors.red,
        duration: Duration(seconds: 1),
      ));
    });

    // Ir a la siguiente pregunta después de 1.5 segundos
    Future.delayed(Duration(seconds: 1), () {
      if (preguntaIndex < widget.preguntas.length - 1) {
        _pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
      } else {
        _mostrarResultado();
      }
    });
  }

  void _mostrarResultado() async {
    await ResultadoService.guardarPuntos(_puntos); // Guarda coins en Firestore
    final dineroGanado = _puntos * 10;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('¡Resultado!', style: GoogleFonts.poppins(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/star.json', width: 100, repeat: false),
            SizedBox(height: 10),
            Text(
              'Obtuviste $_puntos de ${widget.preguntas.length} puntos.',
              style: GoogleFonts.openSans(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Ganaste $dineroGanado monedas ficticias 💰',
              style: GoogleFonts.openSans(fontSize: 16, color: Colors.green[800]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text('Finalizar', style: TextStyle(color: Colors.green)),
          )
        ],
      ),
    );
  }

  Widget _buildPregunta(int index) {
    final pregunta = widget.preguntas[index];
    final imagen = pregunta['imagen'];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pregunta ${index + 1}/${widget.preguntas.length}',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 10),
          if (imagen != null) Image.asset(imagen, height: 150),
          SizedBox(height: 10),
          Text(pregunta['pregunta'], style: GoogleFonts.openSans(fontSize: 16)),
          SizedBox(height: 20),
          ...List.generate(
            pregunta['opciones'].length,
                (i) => Card(
              color: _respuestas[index] == i
                  ? (i == pregunta['respuestaCorrecta']
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.error.withOpacity(0.2))
                  : Theme.of(context).cardColor,
              child: ListTile(
                title: Text(
                  pregunta['opciones'][i],
                  style: GoogleFonts.openSans().merge(Theme.of(context).textTheme.bodyMedium),
                ),
                leading: Icon(Icons.circle_outlined, color: Theme.of(context).iconTheme.color),
                onTap: () => _verificarRespuesta(index, i),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text(widget.titulo, style: GoogleFonts.poppins()),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Desliza solo automáticamente
        itemCount: widget.preguntas.length,
        itemBuilder: (_, index) => _buildPregunta(index),
      ),
    );
  }
}
