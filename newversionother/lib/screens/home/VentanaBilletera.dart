import 'package:flutter/material.dart';
import '../../services/Servicio_Firestore.dart';

class VentanaBilletera extends StatefulWidget {
  final String userId;

  const VentanaBilletera({Key? key, required this.userId}) : super(key: key);

  @override
  _VentanaBilleteraState createState() => _VentanaBilleteraState();
}

class _VentanaBilleteraState extends State<VentanaBilletera> {
  final FirestoreService _firestoreService = FirestoreService();
  double saldoSimulado = 0.0;
  double saldoReal = 0.0;

  @override
  void initState() {
    super.initState();
    _firestoreService.createUserIfNotExists(widget.userId);
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    try {
      var userDoc = await _firestoreService.getUser(widget.userId);
      setState(() {
        saldoSimulado = userDoc['saldoSimulado'] ?? 1000.0;
        saldoReal = userDoc['saldoReal'] ?? 0.0;
      });
    } catch (e) {
      print('Error al cargar los datos del usuario: $e');
    }
  }

  Future<void> _updateBalance(double simuladoChange, double realChange) async {
    saldoSimulado += simuladoChange;
    saldoReal += realChange;

    await _firestoreService.updateUserBalance(widget.userId, saldoSimulado, saldoReal);
    setState(() {});
  }

  void _realizarCompraVenta(bool esCompra) {
    showDialog(
      context: context,
      builder: (context) {
        double cantidad = 0.0;

        return AlertDialog(
          title: Text(esCompra ? 'Comprar Activos' : 'Vender Activos'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Ingrese la cantidad'),
            onChanged: (value) {
              cantidad = double.tryParse(value) ?? 0.0;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (cantidad > 0) {
                  _updateBalance(
                    esCompra ? -cantidad : cantidad,
                    esCompra ? -cantidad : cantidad,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billetera'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu Progreso Financiero',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saldo Simulado', style: TextStyle(fontSize: 16)),
                        Text('\$${saldoSimulado.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saldo Real', style: TextStyle(fontSize: 16)),
                        Text('\$${saldoReal.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _realizarCompraVenta(true),
                  child: Text('Comprar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () => _realizarCompraVenta(false),
                  child: Text('Vender'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
