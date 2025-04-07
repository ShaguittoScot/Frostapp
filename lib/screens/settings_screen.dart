import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String name = '';
  String role = '';
  String profileImageUrl = '';
  int recipesCreated = 0;
  int ingredientsScanned = 0;
  int favorites = 0;

  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
  try {
    // Obtener la cookie del almacenamiento seguro
    String? cookie = await storage.read(key: 'session_cookie');
    
    if (cookie == null || cookie.isEmpty) {
      _showToast("No hay sesión activa");
      return;
    }

    final response = await http.get(
      Uri.parse("https://frostback.onrender.com/appi/usuariosBusc/"),
      headers: {
        'Cookie': cookie, // Envía la cookie directamente
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        name = data["Usuarios"]["nombre"] ?? 'No disponible';
        role = data["Usuarios"]["rol"] ?? 'No disponible';
        // ... otros campos
      });
    } else {
      // Manejo de errores
    }
  } catch (e) {
    // Manejo de excepciones
  }
}

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
          child: Column(
            children: [
              // Foto de perfil
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  profileImageUrl.isNotEmpty
                      ? profileImageUrl
                      : 'https://images.unsplash.com/photo-1574182245530-967d9b3831af?q=80&w=1037&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                ),
              ),
              const SizedBox(height: 16),

              // Nombre de usuario
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              // Rol o descripción
              Text(
                role,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),

              // Estadísticas del usuario
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                /*
                children: [
                  StatColumn(title: 'Recetas ', count: recipesCreated),
                  StatColumn(title: 'Ingredientes ', count: ingredientsScanned),
                  StatColumn(title: 'Favoritos ', count: favorites),
                ],
                */
              ),
              const SizedBox(height: 24),

              // Botón de editar perfil
              /*ElevatedButton(
                onPressed: () {
                  // Lógica para editar perfil
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Editar perfil")));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  'Editar perfil',
                  style: TextStyle(color: Colors.white),
                ),
              ),*/
              const SizedBox(height: 24),
              /*Text(
                "Ajustes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Divider(color: Colors.deepOrangeAccent),
              const SizedBox(height: 24),
              // Opciones de configuración
              ListTile(
                leading: Icon(
                  Icons.account_circle,
                  color: Colors.deepOrangeAccent,
                ),
                title: Text('Cuenta', style: TextStyle(color: Colors.black87)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.help, color: Colors.deepOrangeAccent),
                title: Text('Ayuda', style: TextStyle(color: Colors.black87)),
                onTap: () {},
              ),
              const SizedBox(height: 24),
*/
              // Botón para cerrar sesión
              ElevatedButton(
                onPressed: () async {
                  // Eliminar el token guardado en FlutterSecureStorage
                  final storage = FlutterSecureStorage();
                  await storage.delete(key: 'token');

                  // Mostrar mensaje de sesión cerrada
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Sesión cerrada")));

                  // Redirigir a la pantalla de inicio de sesión
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false, // Elimina todas las pantallas anteriores
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatColumn extends StatelessWidget {
  final String title;
  final int count;

  const StatColumn({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}
