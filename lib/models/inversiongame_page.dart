import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InversionGamePage extends StatefulWidget {
  @override
  _InversionGamePageState createState() => _InversionGamePageState();
}

class _InversionGamePageState extends State<InversionGamePage> {
  final Random random = Random();

  int turno = 1;
  double saldo = 5000;
  double precioAccion = 100;
  int acciones = 0;
  String resultadoTurno = '';
  List<String> historial = [];

  void procesarDecision(String decision) {
    double cambio = (random.nextDouble() * 20) - 10; // Cambio entre -10 y +10
    double nuevoPrecio = (precioAccion + cambio).clamp(1, double.infinity);

    setState(() {
      switch (decision) {
        case 'comprar':
          if (saldo >= nuevoPrecio) {
            saldo -= nuevoPrecio;
            acciones++;
            resultadoTurno = "Turno $turno: Compraste 1 acción a \$${nuevoPrecio.toStringAsFixed(2)}";
          } else {
            resultadoTurno = "Turno $turno: No tienes suficiente saldo para comprar.";
          }
          break;
        case 'vender':
          if (acciones > 0) {
            saldo += nuevoPrecio;
            acciones--;
            resultadoTurno = "Turno $turno: Vendiste 1 acción a \$${nuevoPrecio.toStringAsFixed(2)}";
          } else {
            resultadoTurno = "Turno $turno: No tienes acciones para vender.";
          }
          break;
        case 'mantener':
          resultadoTurno = "Turno $turno: Decidiste mantener. El precio cambió.";
          break;
      }

      historial.add(resultadoTurno);
      precioAccion = nuevoPrecio;
      turno++;
    });
  }

  void finalizarJuego() {
    double valorTotal = saldo + (acciones * precioAccion);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Fin del Desafío"),
        content: Text(
          "Saldo final: \$${saldo.toStringAsFixed(2)}\n"
              "Acciones: $acciones x \$${precioAccion.toStringAsFixed(2)} = \$${(acciones * precioAccion).toStringAsFixed(2)}\n"
              "Total: \$${valorTotal.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Desafío: El Mercado Volátil"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Turno $turno de 10", style: GoogleFonts.poppins(fontSize: 20)),
            SizedBox(height: 10),
            Text("Saldo: \$${saldo.toStringAsFixed(2)}", style: TextStyle(color: Colors.green)),
            Text("Acciones: $acciones", style: TextStyle(color: Colors.blue)),
            Text("Precio Actual: \$${precioAccion.toStringAsFixed(2)}", style: TextStyle(color: Colors.deepPurple)),
            SizedBox(height: 20),
            if (turno <= 10) Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () => procesarDecision('comprar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Comprar")),
                ElevatedButton(
                    onPressed: () => procesarDecision('mantener'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: Text("Mantener")),
                ElevatedButton(
                    onPressed: () => procesarDecision('vender'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Vender")),
              ],
            ),
            if (turno > 10)
              ElevatedButton.icon(
                onPressed: finalizarJuego,
                icon: Icon(Icons.flag),
                label: Text("Ver Resultado Final"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: historial.length,
                itemBuilder: (context, index) => Text(historial[index],
                    style: GoogleFonts.openSans(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
