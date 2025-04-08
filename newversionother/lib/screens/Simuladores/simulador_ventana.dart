import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class simulador_ventana extends StatefulWidget {
  final String tipoInversion;

  const simulador_ventana({super.key, required this.tipoInversion});

  @override
  _SimuladorVentanaState createState() => _SimuladorVentanaState();
}

class _SimuladorVentanaState extends State<simulador_ventana> {
  Map<String, dynamic>? _inversionData;
  double _balance = 10000.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _inversionesDisponibles = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    loadUserBalance();
    cargarListaDeInversiones();
  }

  Future<void> fetchData() async {
    try {
      if (widget.tipoInversion == 'criptomonedas') {
        final cryptoData = await ApiService.fetchCryptoData('bitcoin');
        setState(() {
          _inversionData = cryptoData;
        });
      } else if (widget.tipoInversion == 'acciones') {
        final stockData = await ApiService.fetchStockData('AAPL');
        setState(() {
          _inversionData = stockData;
        });
      } else if (widget.tipoInversion == 'forex') {
        final forexData = await ApiService.fetchForexData('EURUSD');
        setState(() {
          _inversionData = forexData;
        });
      } else if (widget.tipoInversion == 'commodities') {
        final commoditiesData = await ApiService.fetchCommoditiesData('gold');
        setState(() {
          _inversionData = commoditiesData;
        });
      }
    } catch (e) {
      print('Error al obtener datos: $e');
    }
  }

  Future<void> loadUserBalance() async {
    var user = _auth.currentUser;
    if (user != null) {
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _balance = doc.data()?['balance'] ?? 10000.0;
        });
      }
    }
  }

  Future<void> updateUserBalance(double newBalance) async {
    var user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({'balance': newBalance});
    }
  }

  void _buyAsset(double amount) {
    setState(() {
      _balance -= amount;
      updateUserBalance(_balance);
    });
  }

  void _sellAsset(double amount) {
    setState(() {
      _balance += amount;
      updateUserBalance(_balance);
    });
  }

  void cargarListaDeInversiones() {
    if (widget.tipoInversion == 'criptomonedas') {
      _inversionesDisponibles = ['Bitcoin', 'Ethereum', 'Cardano', 'Solana'];
    } else if (widget.tipoInversion == 'acciones') {
      _inversionesDisponibles = ['AAPL', 'GOOGL', 'AMZN', 'MSFT'];
    } else if (widget.tipoInversion == 'forex') {
      _inversionesDisponibles = ['EUR/USD', 'USD/JPY', 'GBP/USD', 'AUD/USD'];
    } else if (widget.tipoInversion == 'commodities') {
      _inversionesDisponibles = ['Oro', 'Plata', 'Petróleo', 'Cobre'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simulador ${widget.tipoInversion}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Balance: \$${_balance.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _buyAsset(500),
              child: const Text('Comprar Activo - \$500'),
            ),
            ElevatedButton(
              onPressed: () => _sellAsset(500),
              child: const Text('Vender Activo + \$500'),
            ),
            const SizedBox(height: 20),
            Text('Gráfico de ${widget.tipoInversion}'),
            SizedBox(height: 200, child: _buildInversionChart()),
            const SizedBox(height: 20),
            Expanded(child: _buildInvestmentList()),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentList() {
    return ListView.builder(
      itemCount: _inversionesDisponibles.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_inversionesDisponibles[index]),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            print('Seleccionaste: ${_inversionesDisponibles[index]}');
          },
        );
      },
    );
  }

  Widget _buildInversionChart() {
    if (_inversionData == null) return const CircularProgressIndicator();

    if (widget.tipoInversion == 'criptomonedas') {
      return _buildCryptoChart();
    } else if (widget.tipoInversion == 'acciones') {
      return _buildStockChart();
    } else if (widget.tipoInversion == 'forex') {
      return const Text('Gráfico de Forex aún no implementado.');
    } else if (widget.tipoInversion == 'commodities') {
      return const Text('Gráfico de Commodities aún no implementado.');
    } else {
      return Container();
    }
  }
  Widget _buildCryptoChart() {
    final List<dynamic> prices = _inversionData!['prices'] ?? [];
    List<FlSpot> spots = prices.asMap().entries.map((entry) {
      int index = entry.key;
      double price = entry.value[1].toDouble();
      return FlSpot(index.toDouble(), price);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildStockChart() {
    if (_inversionData == null || !_inversionData!.containsKey('Time Series (Daily)')) {
      return const Text('No hay datos disponibles.');
    }

    final Map<String, dynamic> timeSeries = _inversionData!['Time Series (Daily)'];
    final List<FlSpot> spots = [];
    int index = 0;

    timeSeries.forEach((date, data) {
      if (data.containsKey('4. close')) {
        double closePrice = double.tryParse(data['4. close']) ?? 0.0;
        spots.add(FlSpot(index.toDouble(), closePrice));
        index++;
      }
    });

    if (spots.isEmpty) {
      return const Text('No se pudieron cargar datos.');
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots.reversed.toList(),
            isCurved: true,
            color: Colors.green,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

}