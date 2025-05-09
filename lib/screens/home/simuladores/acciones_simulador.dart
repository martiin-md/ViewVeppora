import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class acciones_simulador extends StatefulWidget {
  const acciones_simulador({super.key});

  @override
  State<acciones_simulador> createState() => _AccionesSimuladorState();
}

class _AccionesSimuladorState extends State<acciones_simulador> {
  final List<String> acciones = ["AAPL", "MSFT", "GOOG", "AMZN"];
  String _selected = "AAPL";
  double _price = 0.0;
  double _capital = 10000.0;
  Map<String, int> _portafolio = {};
  late final WebViewController _webViewController;
  final TextEditingController _cantidadController = TextEditingController();

  String? _userId;
  bool _cargando = true;

  final String apiKey = 'YI5AN66F8YECRIQ8';  // Reemplazar con tu clave de Alpha Vantage

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

  // Método para obtener el precio de la acción de una API externa (Alpha Vantage)
  Future<void> _updatePrecio() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$_selected&interval=5min&apikey=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timeSeries = data['Time Series (5min)'];
        if (timeSeries != null) {
          final latestTime = timeSeries.keys.first;
          final latestData = timeSeries[latestTime];
          final double latestPrice = double.tryParse(latestData['4. close']) ?? 0.0;

          setState(() {
            _price = latestPrice;
          });
        }
      } else {
        throw Exception('Error al obtener los datos de la API');
      }
    } catch (e) {
      print("Error al obtener precio: $e");
    }
  }

  Future<void> _loadDatosUsuario() async {
    if (_userId == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(_userId).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _capital = (data['saldoSimulado'] ?? 10000).toDouble();
        if (data.containsKey('portafolioSimulado')) {
          final p = Map<String, dynamic>.from(data['portafolioSimulado']);
          _portafolio = p.map((k, v) => MapEntry(k, v as int));
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
      'saldoSimulado': _capital,
      'portafolioSimulado': _portafolio,
    });
  }

  Future<void> _registrarTransaccion(String tipo, int cantidad) async {
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
        'saldoPostOperacion': _capital,
        'fecha': Timestamp.now(),
      });
  }


  void _cambiarAccion(String accion) {
    setState(() {
      _selected = accion;
      _updatePrecio();
      _webViewController.runJavaScript("setSymbol('$_selected')");
    });
  }

  void _comprar() async {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;
    double costoTotal = cantidad * _price;
    if (_capital >= costoTotal && cantidad > 0) {
      setState(() {
        _capital -= costoTotal;
        _portafolio[_selected] = (_portafolio[_selected] ?? 0) + cantidad;
        _cantidadController.clear();
      });
      await _guardarDatosUsuario();
      await _registrarTransaccion("compra", cantidad);
    }
  }

  void _vender() async {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;
    int cantidadActual = _portafolio[_selected] ?? 0;
    if (cantidad > 0 && cantidad <= cantidadActual) {
      setState(() {
        _capital += cantidad * _price;
        _portafolio[_selected] = cantidadActual - cantidad;
        if (_portafolio[_selected] == 0) _portafolio.remove(_selected);
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
      appBar: AppBar(title: const Text("Simulador de Acciones")),
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
                onChanged: (valor) => _cambiarAccion(valor!),
                items: acciones.map((accion) => DropdownMenuItem(
                  value: accion,
                  child: Text(accion),
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
              ..._portafolio.entries.map((entry) => Text("${entry.key}: ${entry.value} acciones")),
            ],
          ),
        ),
      ),
    );
  }
}
