import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newversion/screens/home/VentanaPrincipalHome.dart';
import 'package:newversion/screens/Logins/VentanaInicioSesionLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newversion/screens/ajustes/VentanaAjustes.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ViewVepporaApp());
}

class ViewVepporaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'View Veppora',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.teal,
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.teal,
            ),
            home: AuthWrapper(),
            routes: {
              '/home': (_) => VentanaPrincipalHome(onThemeToggle: themeProvider.toggleTheme),
              '/ajustes': (_) => VentanaAjustes(onThemeToggle: themeProvider.toggleTheme),
            },
          );
        },
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Cargar el tema desde SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();  // Notificar a los widgets cuando se carga el tema
  }

  // Cambiar el tema y guardarlo
  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();  // Notificar a los widgets que el tema ha cambiado
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<void> _checkAndCreateUserData(String userId) async {
    final docRef = FirebaseFirestore.instance.collection('usuarios').doc(userId);
    final doc = await docRef.get();

    final data = doc.data() ?? {};

    if (!doc.exists || !data.containsKey('progresoCurso')) {
      await docRef.set({
        'saldoSimulado': data['saldoSimulado'] ?? 50000000.0,
        'portafolioAcciones': data['portafolioAcciones'] ?? {},
        'portafolioCripto': data['portafolioCripto'] ?? {},
        'portafolioCommodities': data['portafolioCommodities'] ?? {},
        'progresoCurso': 0, // NIVEL PRINCIPIANTE
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder(
            future: _checkAndCreateUserData(snapshot.data!.uid),
            builder: (context, snapshotFuture) {
              if (snapshotFuture.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                return VentanaPrincipalHome(onThemeToggle: () {});
              }
            },
          );
        } else {
          return VentanaInicioSesionLogin();
        }
      },
    );
  }
}
