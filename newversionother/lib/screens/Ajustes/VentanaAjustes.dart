import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VentanaAjustes extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const VentanaAjustes({super.key, required this.onThemeToggle});

  @override
  _VentanaAjustesState createState() => _VentanaAjustesState();
}

class _VentanaAjustesState extends State<VentanaAjustes> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Cargar el tema guardado desde SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Cambiar el tema y guardarlo en SharedPreferences
  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
    });
    prefs.setBool('isDarkMode', value);
    widget.onThemeToggle(); // Notifica al padre para que cambie el tema global
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          // Switch para cambiar entre modo claro y oscuro
          SwitchListTile(
            title: Text('Modo oscuro'),
            value: isDarkMode,
            onChanged: (bool value) {
              _toggleTheme(value); // Llama al método para cambiar el tema
            },
            secondary: Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Eliminar cuenta'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Confirmar'),
                  content: Text('¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.'),
                  actions: [
                    TextButton(
                      child: Text('Cancelar'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cuenta eliminada exitosamente')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.blue),
            title: Text('Centro de Ayuda'),
            onTap: () {

            },
          ),
          ListTile(
            leading: Icon(Icons.star_rate, color: Colors.amber),
            title: Text('Puntuar la App'),
            onTap: () {

            },
          ),
        ],
      ),
    );
  }
}
