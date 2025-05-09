import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newversion/screens/home/analisis/acciones_analisis.dart';
import 'package:newversion/screens/home/analisis/commodities_analisis.dart';
import 'package:newversion/screens/home/analisis/cripto_analisis.dart';
import 'package:newversion/screens/home/analisis/forex_analisis.dart';

class VentanaAnalisisGraficos extends StatefulWidget {
  const VentanaAnalisisGraficos({super.key});

  @override
  State<VentanaAnalisisGraficos> createState() => _VentanaAnalisisGraficosState();
}

class _VentanaAnalisisGraficosState extends State<VentanaAnalisisGraficos> {
  bool _isPremium = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkPremiumStatus();
  }

  // Función para verificar el estado premium del usuario
  Future<void> checkPremiumStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Si el usuario no está autenticado, se establece el estado como no premium
    if (uid == null) {
      setState(() {
        _isPremium = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

      // Si el documento no existe, se establece el estado como no premium
      if (!userDoc.exists) {
        setState(() {
          _isPremium = false;
          _isLoading = false;
        });
        return;
      }

      final data = userDoc.data();

      // Verifica si el usuario tiene premium como true
      if (data != null && data['premium'] == true) {
        final premiumExpira = data['premium_expira'];

        // Verifica si la fecha de expiración existe y si es un formato adecuado
        if (premiumExpira != null) {
          DateTime? expiraDate;

          // Si 'premium_expira' es un Timestamp, lo convertimos a DateTime
          if (premiumExpira is Timestamp) {
            expiraDate = premiumExpira.toDate();
          } else if (premiumExpira is String) {
            // Si es un String, intentamos convertirlo a DateTime
            expiraDate = DateTime.tryParse(premiumExpira);
          }

          // Si la fecha de expiración es válida y no ha expirado, el usuario tiene Premium
          if (expiraDate != null && DateTime.now().isBefore(expiraDate)) {
            setState(() {
              _isPremium = true;
              _isLoading = false;
            });
            return;
          }
        }
      }

      // Si no tiene Premium o la fecha ha expirado, establecer en falso
      setState(() {
        _isPremium = false;
        _isLoading = false;
      });
    } catch (e) {
      // Si hay error, establecer el estado correctamente
      setState(() {
        _isPremium = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Análisis del Mercado',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white // Blanco en modo oscuro
                : Colors.black, // Negro en modo claro
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black // Fondo oscuro en modo oscuro
          : Colors.grey[200], // Fondo claro en modo claro
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isPremium
          ? Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explora gráficos y datos en tiempo real.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Blanco en modo oscuro
                    : Colors.black, // Negro en modo claro
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildAnalisisCard(
                    'Acciones',
                    FontAwesomeIcons.chartLine,
                    Colors.blue,
                    acciones_analisis(),
                  ),
                  _buildAnalisisCard(
                    'Criptomonedas',
                    FontAwesomeIcons.coins,
                    Colors.orange,
                    cripto_analisis(),
                  ),
                  _buildAnalisisCard(
                    'Forex',
                    FontAwesomeIcons.dollarSign,
                    Colors.purple,
                    forex_analisis(),
                  ),
                  _buildAnalisisCard(
                    'Commodities',
                    FontAwesomeIcons.boxOpen,
                    Colors.red,
                    commodities_analisis(),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 60, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Esta sección está disponible solo para Contenido Premium.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white // Blanco en modo oscuro
                    : Colors.black, // Negro en modo claro
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget que crea las tarjetas para cada tipo de análisis
  Widget _buildAnalisisCard(String title, IconData icon, Color color, Widget analysisPage) {
    return OpenContainer(
      closedColor: Colors.white,
      openColor: Colors.white,
      closedElevation: 5,
      openElevation: 0,
      transitionDuration: Duration(milliseconds: 500),
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      openBuilder: (context, _) => analysisPage,
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: color, size: 40),
                SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white // Blanco en modo oscuro
                        : Colors.black, // Negro en modo claro
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
