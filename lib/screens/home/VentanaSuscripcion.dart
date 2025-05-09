import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newversion/services/Servicio_Firestore.dart';

class VentanaSuscripcion extends StatefulWidget {
  final String userId;

  const VentanaSuscripcion({Key? key, required this.userId}) : super(key: key);

  @override
  _VentanaSuscripcionState createState() => _VentanaSuscripcionState();
}

class _VentanaSuscripcionState extends State<VentanaSuscripcion> {
  final FirestoreService firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _verificarYActualizarSuscripcion();
  }

  Future<void> _verificarYActualizarSuscripcion() async {
    final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(widget.userId).get();
    final data = userDoc.data();
    if (data == null) return;

    final esPremium = data['premium'] == true;
    final rawFecha = data['premium_expira'];

    DateTime? fechaExpira;
    if (rawFecha is Timestamp) {
      fechaExpira = rawFecha.toDate();  // Convertimos Timestamp a DateTime
    }

    if (esPremium && fechaExpira != null && DateTime.now().isAfter(fechaExpira)) {
      await FirebaseFirestore.instance.collection('usuarios').doc(widget.userId).update({
        'premium': false,
        'premium_expira': null,  // Limpia la fecha de expiración
      });
      setState(() {});
    }
  }

  Future<void> comprarSuscripcionPremium() async {
    final resultado = await firestore.comprarSuscripcionPremium(widget.userId, firestore);

    if (resultado.contains('activada')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suscripción Premium Activa.')),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .collection('simulaciones')
          .add({
        'tipo': 'suscripción',
        'monto': 80.0,
        'fecha': Timestamp.now(),
        'descripcion': 'Compra Premium',
      });

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado)));
    }
  }

  Future<void> cancelarSuscripcion() async {
    final usuarioRef = FirebaseFirestore.instance.collection('usuarios').doc(widget.userId);

    await usuarioRef.update({
      'premium': false,
      'premium_expira': null,
    });

    await usuarioRef.collection('simulaciones').add({
      'tipo': 'cancelación',
      'monto': 0.0,
      'fecha': Timestamp.now(),
      'descripcion': 'Cancelación Premium',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suscripción Premium cancelada.')),
    );

    setState(() {});
  }

  void _mostrarDialogoCancelacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancelar Suscripción"),
        content: const Text("¿Estás seguro de que deseas cancelar tu suscripción Premium? Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text("Volver")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              cancelarSuscripcion();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sí, Cancelar"),
          ),
        ],
      ),
    );
  }

  String _formatoFecha(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final userStream = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.userId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripciones'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.deepPurple // Color oscuro en modo oscuro
            : Colors.indigo,    // Color claro en modo claro
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]  // Fondo oscuro en modo oscuro
          : Colors.grey[100], // Fondo claro en modo claro
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige tu Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Blanco en modo oscuro
                    : Colors.black, // Negro en modo claro
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<DocumentSnapshot>(
              stream: userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Cargando...');
                }

                if (!snapshot.hasData || snapshot.hasError) {
                  return const Text('Error al cargar datos');
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final esPremium = userData['premium'] == true;

                final rawFecha = userData['premium_expira'];
                DateTime? fechaExpira;
                if (rawFecha is Timestamp) {
                  fechaExpira = rawFecha.toDate();
                }

                final planActual = esPremium ? 'Premium' : 'Free';
                final fechaExpiraTexto = esPremium && fechaExpira != null
                    ? 'Suscripción activa hasta: ${_formatoFecha(fechaExpira)}'
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan actual: $planActual',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white // Blanco en modo oscuro
                            : Colors.black, // Negro en modo claro
                      ),
                    ),
                    if (fechaExpiraTexto != null)
                      Text(
                        fechaExpiraTexto,
                        style: const TextStyle(fontSize: 14, color: Colors.green),
                      ),
                    const SizedBox(height: 20),
                    subscriptionCard(
                      'Free',
                      'Acceso limitado en algunas Funcionalidades.',
                      Icons.lock_open,
                      Colors.green,
                          () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ya estás en el plan Free.'))),
                    ),
                    const SizedBox(height: 20),
                    subscriptionCard(
                      'Premium',
                      'Acceso completo con Funcionalidades Avanzadas.',
                      Icons.star,
                      Colors.amber,
                      esPremium
                          ? () => _mostrarDialogoCancelacion(context)
                          : comprarSuscripcionPremium,
                      precio: 80.0,
                      esActivo: esPremium,
                      button: esPremium
                          ? Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: ElevatedButton.icon(
                          onPressed: () => _mostrarDialogoCancelacion(context),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancelar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                          : null,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget subscriptionCard(
      String title,
      String description,
      IconData icon,
      Color iconColor,
      VoidCallback onTap, {
        double? precio,
        bool esActivo = false,
        Widget? button,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]  // Fondo oscuro en modo oscuro
            : Colors.white,     // Fondo claro en modo claro
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(description),
                    if (precio != null)
                      Text(
                        esActivo ? 'Estado: Activo' : 'Costo: \$${precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: esActivo ? Colors.green : Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              if (button != null) button,
            ],
          ),
        ),
      ),
    );
  }
}
