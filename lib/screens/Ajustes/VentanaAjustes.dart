import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newversion/main.dart'; // Asegúrate de importar el ThemeProvider

class VentanaAjustes extends StatelessWidget {
  const VentanaAjustes({super.key, required this.onThemeToggle});
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Modo oscuro'),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme(); // ¡Aquí se notifica automáticamente!
              onThemeToggle(); // Llamada opcional si necesitas forzar algo extra
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
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.star_rate, color: Colors.amber),
            title: Text('Puntuar la App'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
