import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class forex_simulador extends StatefulWidget {
  const forex_simulador({super.key});

  @override
  State<forex_simulador> createState() => _ForexSimuladorState();
}

class _ForexSimuladorState extends State<forex_simulador> {
  final List<String> pares = ["EUR/USD", "USD/JPY", "GBP/USD", "USD/CHF"];
  String _selected = "EUR/USD";
  double _precio = 0.0;
  double _capital = 10000.0;
  Map<String, double> _portafolio = {};
  late final WebViewController _webViewController;
  final TextEditingController _cantidadController = TextEditingController();

  String? _userId;
  bool _cargando = true;

  final String apiKey = 'YI5AN66F8YECRIQ8';

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/tradingview.html')
      ..runJavaScript("setSymbol('${_symbolTradingView(_selected)}')");

    _updatePrecio();
    _loadDatosUsuario();
  }

  String _symbolTradingView(String par) {
    final mapa = {
      "EUR/USD": "OANDA:EURUSD",
      "USD/JPY": "OANDA:USDJPY",
      "GBP/USD": "OANDA:GBPUSD",
      "USD/CHF": "OANDA:USDCHF",
    };
    return mapa[par] ?? "OANDA:EURUSD";
  }

  Future<void> _updatePrecio() async {
    final symbol = _selected.replaceAll("/", "");
    try {
      final response = await http.get(Uri.parse(
          'https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=${_selected.split('/')[0]}&to_currency=${_selected.split('/')[1]}&apikey=$apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final exchangeRate = data['Realtime Currency Exchange Rate']?['5. Exchange Rate'];
        final double precioActual = double.tryParse(exchangeRate ?? '0') ?? 0;

        setState(() {
          _precio = precioActual;
        });
      }
    } catch (e) {
      print("Error al obtener el precio: $e");
    }
  }

  Future<void> _loadDatosUsuario() async {
    if (_userId == null) return;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(_userId).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _capital = (data['saldoSimuladoForex'] ?? 10000).toDouble();
        if (data.containsKey('portafolioSimuladoForex')) {
          final p = Map<String, dynamic>.from(data['portafolioSimuladoForex']);
          _portafolio = p.map((k, v) => MapEntry(k, (v as num).toDouble()));
        }
        _cargando = false;
      });
    } else {
      _cargando = false;
    }
  }

  Future<void> _guardarDatosUsuario() async {
    if (_userId == null) return;
    await FirebaseFirestore.instance.collection('usuarios').doc(_userId).update({
      'saldoSimuladoForex': _capital,
      'portafolioSimuladoForex': _portafolio,
    });
  }

  Future<void> _registrarTransaccion(String tipo, double cantidad) async {
    if (_userId == null) return;

    final double monto = cantidad * _precio;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_userId)
        .collection('simulaciones')
        .add({
      'tipo': tipo,
      'activo': _selected,
      'cantidad': cantidad,
      'precio': _precio,
      'monto': monto,
      'saldoPostOperacion': _capital,
      'fecha': Timestamp.now(),
    });
  }

  void _cambiarPar(String par) {
    setState(() {
      _selected = par;
      _updatePrecio();
      _webViewController.runJavaScript("setSymbol('${_symbolTradingView(_selected)}')");
    });
  }

  void _comprar() async {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    double costo = cantidad * _precio;

    if (_capital >= costo && cantidad > 0) {
      setState(() {
        _capital -= costo;
        _portafolio[_selected] = (_portafolio[_selected] ?? 0) + cantidad;
        _cantidadController.clear();
      });
      await _guardarDatosUsuario();
      await _registrarTransaccion("compra", cantidad);
    }
  }

  void _vender() async {
    double cantidad = double.tryParse(_cantidadController.text) ?? 0;
    double cantidadActual = _portafolio[_selected] ?? 0;
    if (cantidad > 0 && cantidad <= cantidadActual) {
      setState(() {
        _capital += cantidad * _precio;
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Simulador de Forex")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Capital disponible: \$${_capital.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selected,
                onChanged: (valor) => _cambiarPar(valor!),
                items: pares.map((par) => DropdownMenuItem(value: par, child: Text(par))).toList(),
              ),
              const SizedBox(height: 10),
              Text("Precio actual: ${_precio.toStringAsFixed(4)}"),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: WebViewWidget(controller: _webViewController),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _cantidadController,
                decoration: const InputDecoration(labelText: "Cantidad de lotes"),
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
              ..._portafolio.entries.map((e) => Text("${e.key}: ${e.value.toStringAsFixed(2)} lotes")),
            ],
          ),
        ),
      ),
    );
  }
}
