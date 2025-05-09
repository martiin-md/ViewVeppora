import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class criptos_simulador extends StatefulWidget {
  const criptos_simulador({super.key});

  @override
  State<criptos_simulador> createState() => _CriptosSimuladorState();
}

class _CriptosSimuladorState extends State<criptos_simulador> {
  final List<String> criptos = ["BINANCE:BTCUSDT", "BINANCE:ETHUSDT", "BINANCE:SOLUSDT", "BINANCE:XRPUSDT"];
  String _selected = "BINANCE:BTCUSDT";
  double _price = 0.0;
  double _saldoSimulado = 50000000.0;
  Map<String, double> _portafolio = {};
  late final WebViewController _webViewController;
  final TextEditingController _cantidadController = TextEditingController();

  String? _userId;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/tradingview.html')
      ..runJavaScript("setSymbol('$_selected')");

    _updatePrecio();
    _loadDatosUsuario();
  }

  void _updatePrecio() {
    // Simulación de precios diferentes
    setState(() {
      _price = 20000 + (criptos.indexOf(_selected) * 5000).toDouble();
    });
  }

  Future<void> _loadDatosUsuario() async {
    if (_userId == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(_userId).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _saldoSimulado = (data['saldoSimulado'] ?? 50000000).toDouble();
        if (data.containsKey('portafolioCripto')) {
          final p = Map<String, dynamic>.from(data['portafolioCripto']);
          _portafolio = p.map((k, v) => MapEntry(k, (v as num).toDouble()));
        }
        _cargando = false;
      });
    } else {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _guardarDatosUsuario() async {
    if (_userId == null) return;

    await FirebaseFirestore.instance.collection('usuarios').doc(_userId).update({
      'saldoSimulado': _saldoSimulado,
      'portafolioCripto': _portafolio,
    });
  }

  Future<void> _registrarTransaccion(String tipo, double cantidad) async {
    if (_userId == null) return;

    final double monto = cantidad * _price;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_userId)
        .collection('simulaciones')
        .add({
      'tipo': tipo,
      'activo': _selected,
      'cantidad': cantidad,
      'precio': _price,
      'monto': monto,
      'saldoPostOperacion': _saldoSimulado,
      'tipoMercado': 'cripto',
      'fecha': Timestamp.now(),
    });
  }

  void _cambiarCripto(String cripto) {
    setState(() {
      _selected = cripto;
      _updatePrecio();
      _webViewController.runJavaScript("setSymbol('$_selected')");
    });
  }

  void _comprar() async {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    double costoTotal = cantidad * _price;

    print("Intentando comprar $cantidad a precio $_price");

    if (_saldoSimulado >= costoTotal && cantidad > 0) {
      setState(() {
        _saldoSimulado -= costoTotal;
        _portafolio[_selected] = (_portafolio[_selected] ?? 0) + cantidad;
        _cantidadController.clear();
      });

      print("Compra válida, guardando datos...");
      await _guardarDatosUsuario();
      await _registrarTransaccion("compra", cantidad);
      print("Compra registrada.");
    } else {
      print("Compra inválida: saldo insuficiente o cantidad incorrecta");
    }
  }


  void _vender() async {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    double cantidadActual = _portafolio[_selected] ?? 0;

    if (cantidad > 0 && cantidad <= cantidadActual) {
      setState(() {
        _saldoSimulado += cantidad * _price;
        _portafolio[_selected] = cantidadActual - cantidad;
        if (_portafolio[_selected]! <= 0) _portafolio.remove(_selected);
        _cantidadController.clear();
      });

      await _guardarDatosUsuario();
      await _registrarTransaccion("venta", cantidad);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Simulador de Criptomonedas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Capital disponible: \$${_saldoSimulado.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selected,
                onChanged: (valor) => _cambiarCripto(valor!),
                items: criptos
                    .map((cripto) => DropdownMenuItem(
                  value: cripto,
                  child: Text(cripto),
                ))
                    .toList(),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const Text("Portafolio:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ..._portafolio.entries.map((entry) =>
                  Text("${entry.key}: ${entry.value.toStringAsFixed(6)}")),
            ],
          ),
        ),
      ),
    );
  }
}
