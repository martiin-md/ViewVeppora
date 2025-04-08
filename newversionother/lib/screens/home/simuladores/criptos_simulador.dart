import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class criptos_simulador extends StatefulWidget {
  const criptos_simulador({super.key});

  @override
  State<criptos_simulador> createState() => _CriptoSimuladorState();
}

class _CriptoSimuladorState extends State<criptos_simulador> {
  final List<String> criptos = ["BTCUSD", "ETHUSD", "SOLUSD", "XRPUSD"];
  String _selected = "BTCUSD";
  double _price = 0.0;
  double _capital = 5000.0;
  Map<String, int> _portafolio = {};
  late final WebViewController _webViewController;

  final TextEditingController _cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updatePrecio();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/tradingview.html')
      ..runJavaScript("setSymbol('$_selected')");
  }

  void _cambiarCripto(String cripto) {
    setState(() {
      _selected = cripto;
      _updatePrecio();
      _webViewController.runJavaScript("setSymbol('$_selected')");
    });
  }

  void _updatePrecio() {
    setState(() {
      _price = 20000 + (criptos.indexOf(_selected) * 5000).toDouble();
    });
  }

  void _comprar() {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;
    double costoTotal = cantidad * _price;
    if (_capital >= costoTotal && cantidad > 0) {
      setState(() {
        _capital -= costoTotal;
        _portafolio[_selected] = (_portafolio[_selected] ?? 0) + cantidad;
        _cantidadController.clear();
      });
    }
  }

  void _vender() {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;
    int cantidadActual = _portafolio[_selected] ?? 0;
    if (cantidad > 0 && cantidad <= cantidadActual) {
      setState(() {
        _capital += cantidad * _price;
        _portafolio[_selected] = cantidadActual - cantidad;
        if (_portafolio[_selected] == 0) _portafolio.remove(_selected);
        _cantidadController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulador de Criptomonedas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Capital disponible: \$${_capital.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selected,
              onChanged: (valor) => _cambiarCripto(valor!),
              items: criptos.map((cripto) => DropdownMenuItem(
                value: cripto,
                child: Text(cripto),
              )).toList(),
            ),
            const SizedBox(height: 10),
            Text("Precio actual: \$${_price.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: WebViewWidget(controller: _webViewController),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: "Cantidad"),
              keyboardType: TextInputType.number,
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
            ..._portafolio.entries.map((entry) => Text("${entry.key}: ${entry.value}")),
          ],
        ),
      ),
    );
  }
}
