import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frost_/widgets/wave_painter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  void _registerUser() async {
    // Obtener datos de los controladores
    String userName = _usernameController.text.trim();
    String nombre =
        "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validaciones
    if (userName.isEmpty || nombre.isEmpty || email.isEmpty || password.isEmpty) {
      _showToast("Por favor complete todos los campos");
      return;
    }

    if (password != confirmPassword) {
      _showToast("Las contraseñas no coinciden");
      return;
    }

    if (!_isEmailValid(email)) {
      _showToast("Ingrese un email válido");
      return;
    }

    // Crear el cuerpo exactamente como en Postman
    Map<String, dynamic> requestBody = {
      "userName": userName,
      "nombre": nombre,
      "email": email,
      "password": password,
    };

    try {
      // Enviar la solicitud con los headers correctos
      final response = await http
          .post(
            Uri.parse("https://frostback.onrender.com/appi/register"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json", // Asegúrate de que este header esté presente
            },
            body: jsonEncode(requestBody), // Codificar como JSON
          )
          .timeout(Duration(seconds: 15));

      // Verifica el estado de la respuesta
      final responseData = jsonDecode(response.body);
      print('Response Status: ${response.statusCode}');  // Imprimir el estado de la respuesta
      print('Response Body: ${response.body}');  // Imprimir el cuerpo de la respuesta

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showToast("Registro exitoso!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        _showToast(
          responseData["message"] ?? "Error en el registro (${response.statusCode})",
        );
      }
    } on http.ClientException catch (e) {
      _showToast("Error de conexión: ${e.message}");
    } on TimeoutException {
      _showToast("Tiempo de espera agotado");
    } catch (e) {
      _showToast("Error inesperado: ${e.toString()}");
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Regístrate en Frost',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C274C),
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  hintText: 'Nombre',
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
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  hintText: 'Apellido',
                                  prefixIcon: Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: TextStyle(color: Color(0xFF1C274C)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Nombre de usuario',
                            prefixIcon: Icon(Icons.person_pin),
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
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: Color(0xFF1C274C)),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(color: Color(0xFF1C274C)),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_confirmPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Confirmar contraseña',
                            prefixIcon: Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _confirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(color: Color(0xFF1C274C)),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1C274C),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Center(child: Text('Registrarse')),
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            '¿Ya tienes una cuenta? Inicia sesión aquí.',
                            style: TextStyle(
                              color: Color(0xFF1C274C),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
