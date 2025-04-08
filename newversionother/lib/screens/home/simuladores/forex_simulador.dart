import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class forex_simulador extends StatefulWidget {
  const forex_simulador({super.key});

  @override
  State<forex_simulador> createState() => _SimuladorForexState();
}

class _SimuladorForexState extends State<forex_simulador> {
  final List<String> pares = ["EUR/USD", "USD/JPY", "GBP/USD", "USD/CHF"];
  String _selected = "EUR/USD";
  double _precio = 0.0;
  double _capital = 10000.0;
  Map<String, double> _portafolio = {};
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _actualizarPrecio();
  }

  void _actualizarPrecio() {
    setState(() {
      _precio = 1.05 + (pares.indexOf(_selected) * 0.1);
    });
  }

  void _cambiarPar(String par) {
    setState(() {
      _selected = par;
      _actualizarPrecio();
    });
  }

  void _comprar() {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0.0;
    double costo = cantidad * _precio;

    if (_capital >= costo && cantidad > 0) {
      setState(() {
        _capital -= costo;
        _portafolio[_selected] = (_portafolio[_selected] ?? 0) + cantidad;
        _cantidadController.clear();
      });
    }
  }

  void _vender() {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0.0;
    double cantidadActual = _portafolio[_selected] ?? 0.0;

    if (cantidad > 0 && cantidad <= cantidadActual) {
      setState(() {
        _capital += cantidad * _precio;
        _portafolio[_selected] = cantidadActual - cantidad;
        if (_portafolio[_selected]! <= 0) _portafolio.remove(_selected);
        _cantidadController.clear();
      });
    }
  }

  Widget _graficoSimulado() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: false),
              spots: List.generate(10, (i) {
                double y = _precio * (1 + (i - 5) * 0.002);
                return FlSpot(i.toDouble(), y);
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulador Forex")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Capital disponible: \$${_capital.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selected,
              onChanged: (valor) => _cambiarPar(valor!),
              items: pares.map((par) => DropdownMenuItem(
                value: par,
                child: Text(par),
              )).toList(),
            ),
            const SizedBox(height: 10),
            Text("Precio actual: ${_precio.toStringAsFixed(4)}"),
            const SizedBox(height: 10),
            _graficoSimulado(),
            const SizedBox(height: 20),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: "Cantidad"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(onPressed: _comprar, child: const Text("Comprar")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _vender, child: const Text("Vender")),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Portafolio:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ..._portafolio.entries.map((e) =>
                Text("${e.key}: ${e.value.toStringAsFixed(2)} lotes")),
          ],
        ),
      ),
    );
  }
}
