import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VentanaBilletera extends StatefulWidget {
  final String userId;
  const VentanaBilletera({Key? key, required this.userId}) : super(key: key);

  @override
  State<VentanaBilletera> createState() => _BilleteraSimuladaState();
}

class _BilleteraSimuladaState extends State<VentanaBilletera> {
  double saldoSimulado = 0.0;
  List<Map<String, dynamic>> transacciones = [];

  @override
  void initState() {
    super.initState();
    _cargarSaldoYTransacciones();
  }

  Future<void> _cargarSaldoYTransacciones() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          saldoSimulado = (userDoc.data()?['saldoSimulado'] ?? 0.0).toDouble();
        });
      }

      final transSnap = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .collection('simulaciones')
          .orderBy('fecha', descending: true)
          .get();

      setState(() {
        transacciones =
            transSnap.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("Error al cargar datos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billetera Simulada'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Saldo Simulado Actual:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Blanco en modo oscuro
                    : Colors.black, // Negro en modo claro
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800] // Fondo oscuro en modo oscuro
                  : Colors.lightBlue[50], // Fondo claro en modo claro
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: Text(
                  "\$${saldoSimulado.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Historial de Transacciones:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Blanco en modo oscuro
                    : Colors.black, // Negro en modo claro
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: transacciones.isEmpty
                  ? Center(
                child: Text(
                  "No hay transacciones registradas.",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Blanco en modo oscuro
                        : Colors.black, // Negro en modo claro
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: transacciones.length,
                itemBuilder: (context, index) {
                  final t = transacciones[index];
                  final tipo = t['tipo'] ?? '';
                  final activo = t['activo'] ?? '';
                  final cantidad = t['cantidad'] ?? 0;
                  final precio = t['precio'] ?? 0.0;
                  final fecha = (t['fecha'] as Timestamp).toDate();

                  String titulo;
                  String subtitulo;
                  IconData icono;
                  Color color;

                  if (tipo == 'suscripción') {
                    titulo = 'Compra de Suscripción Premium';
                    subtitulo = 'Costo: 80.00';
                    icono = Icons.star;
                    color = Colors.amber;
                  } else if (tipo == 'cancelación') {
                    titulo = 'Cancelación';
                    subtitulo = 'Sin costo';
                    icono = Icons.cancel;
                    color = Colors.grey;
                  } else {
                    titulo = '$tipo de $activo';
                    subtitulo = 'Cantidad: $cantidad • Precio: \$${precio.toStringAsFixed(2)}';
                    icono = tipo == 'compra' ? Icons.trending_up : Icons.trending_down;
                    color = tipo == 'compra' ? Colors.green : Colors.red;
                  }

                  return Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850] // Fondo oscuro en modo oscuro
                        : Colors.white, // Fondo claro en modo claro
                    child: ListTile(
                      leading: Icon(icono, color: color),
                      title: Text(
                        titulo,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white // Blanco en modo oscuro
                              : Colors.black, // Negro en modo claro
                        ),
                      ),
                      subtitle: Text(
                        subtitulo,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70 // Blanco opaco en modo oscuro
                              : Colors.black87, // Negro más suave en modo claro
                        ),
                      ),
                      trailing: Text(
                        '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
