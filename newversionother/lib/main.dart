import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newversion/screens/home/VentanaPrincipalHome.dart';
import 'package:newversion/screens/Logins/VentanaInicioSesionLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newversion/screens/ajustes/VentanaAjustes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // See lee el valor de SharedPreferences antes de iniciar la app
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(ViewVepporaApp(isDarkMode: isDarkMode));
}

class ViewVepporaApp extends StatelessWidget {
  final bool isDarkMode;

  const ViewVepporaApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkMode),
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
  bool isDarkMode;

  ThemeProvider(this.isDarkMode);

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = !isDarkMode;
    prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return VentanaPrincipalHome(onThemeToggle: () {  },);
    } else {
      return VentanaInicioSesionLogin();
    }
  }
}
