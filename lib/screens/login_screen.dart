import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frost_/widgets/wave_painter.dart';
import 'package:frost_/main.dart';
import 'register_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frost_/main.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;

  Dio dio = Dio(); // Instancia de Dio

  void _loginUser() async {
    String userName = _userNameController.text.trim();
    String password = _passwordController.text.trim();

    if (userName.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Por favor, ingresa tu usuario y contraseña");
      return;
    }

    try {
      final response = await dio.post(
        "https://frostback.onrender.com/appi/login",
        data: jsonEncode({"userName": userName, "password": password}),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      print("Código de respuesta: ${response.statusCode}");
      print("Encabezados de respuesta: ${response.headers}");

      if (response.statusCode == 200) {
        // Obtener la cookie del header 'set-cookie'
        String? rawCookie = response.headers['set-cookie']?.first;

        if (rawCookie == null) {
          Fluttertoast.showToast(msg: "No se recibió cookie de sesión");
          return;
        }

        // Extraer solo la parte relevante de la cookie (antes del primer ';')
        String sessionCookie = rawCookie.split(';').first;
        print("Cookie de sesión: $sessionCookie");

        // Guardar la cookie en SecureStorage
        final storage = FlutterSecureStorage();
        await storage.write(key: 'session_cookie', value: sessionCookie);

        Fluttertoast.showToast(msg: "Inicio de sesión exitoso");

        // Redirigir al home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        Fluttertoast.showToast(msg: "Usuario o contraseña incorrectos");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error de conexión: ${e.toString()}");
      print("Error completo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: FridgeBackgroundPainter(),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Inicia sesión en Frost",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C274C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  TextField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      hintText: "Usuario",
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Color(0xFF1C274C)),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Color(0xFF1C274C)),
                  ),
                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1C274C),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Iniciar sesión",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "¿No tienes una cuenta? Regístrate aquí.",
                      style: TextStyle(
                        color: Color(0xFF1C274C),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
