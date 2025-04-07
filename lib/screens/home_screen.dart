import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frost_/widgets/category_item.dart';
import 'inventory_screen.dart';
import 'recipes_screen.dart';
import 'frutis_screen.dart';
import 'expiring_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double temperatura = 0.0;
  double humedad = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _actualizarSensores();
    // Actualizar cada 10 segundos
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _actualizarSensores();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancelar el timer cuando el widget se destruya
    super.dispose();
  }

  Future<void> _actualizarSensores() async {
    final url = Uri.parse(
      'https://frostback.onrender.com/appi/obtenerTemp',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          temperatura = (data["datos"]["Temperature"] as num).toDouble();
          humedad = (data["datos"]["Humidity"] as num).toDouble();
        });
      } else {
        Fluttertoast.showToast(
          msg: "Error al obtener datos: ${response.statusCode}",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error de conexión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 40, color: Colors.deepOrange),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "¡Hola de nuevo!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "¿Qué vas a preparar hoy?",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24),

            // Sección de Acciones Rápidas
            _buildSectionHeader(
              title: 'Acciones rápidas',
              icon: Icons.bolt,
              iconColor: const Color.fromARGB(255, 119, 119, 9),
              textColor: Colors.black,
            ),
            SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    CategoryItem(
                      icon: ('assets/icons/apple.svg'),
                      color: Colors.green,
                      label: "Frutas y verduras",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FrutasVerdurasScreen(),
                        ),
                      ),
                    ),
                    CategoryItem(
                      icon: ('assets/icons/book-bookmark.svg'),
                      color: Colors.orange,
                      label: "Recetas",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecetasScreen(),
                        ),
                      ),
                    ),
                    CategoryItem(
                      icon: ('assets/icons/fridge.svg'),
                      color: Colors.blue,
                      label: "Inventario",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InventarioScreen(),
                        ),
                      ),
                    ),
                    CategoryItem(
                      icon: ('assets/icons/info-circle.svg'),
                      color: Colors.red,
                      label: "Próximos a vencer",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpiringInventoryScreen(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 24),

            // Sección de Estado del Refrigerador
            _buildSectionHeader(
              title: 'Estado del refrigerador',
              icon: ('assets/icons/fridge.svg'),
              iconColor: Colors.blueAccent,
              textColor: Colors.black,
            ),
            SizedBox(height: 12),
            Column(
              children: [
                _buildExtendedRefriCard(
                  icon: Icons.thermostat,
                  title: "Temperatura actual",
                  value: "${temperatura.toStringAsFixed(1)}°C",
                  status: _getTempStatus(temperatura),
                  color: Colors.red[50]!,
                  iconColor: Colors.red[700]!,
                  optimalRange: "3°C - 5°C",
                ),
                SizedBox(height: 16),
                _buildExtendedRefriCard(
                  icon: Icons.water_drop,
                  title: "Humedad actual",
                  value: "${humedad.toStringAsFixed(1)}%",
                  status: _getHumidityStatus(humedad),
                  color: Colors.blue[50]!,
                  iconColor: Colors.blue[700]!,
                  optimalRange: "70% - 80%",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required dynamic icon,
    Color iconColor = Colors.deepOrange,
    Color textColor = Colors.grey,
    double iconSize = 20,
    double fontSize = 18,
  }) {
    return Row(
      children: [
        if (icon is IconData) Icon(icon, size: iconSize, color: iconColor),
        if (icon is String)
          SvgPicture.asset(
            icon,
            width: iconSize,
            height: iconSize,
            color: iconColor,
          ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildExtendedRefriCard({
    required IconData icon,
    required String title,
    required String value,
    required String status,
    required Color color,
    required Color iconColor,
    required String optimalRange,
  }) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(status).withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rango óptimo: $optimalRange",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  "Actualizado: ${TimeOfDay.now().format(context)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTempStatus(double temp) {
    if (temp < 3) return 'BAJA';
    if (temp > 5) return 'ALTA';
    return 'ÓPTIMA';
  }

  String _getHumidityStatus(double hum) {
    if (hum < 70) return 'BAJA';
    if (hum > 80) return 'ALTA';
    return 'ÓPTIMA';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ÓPTIMA':
        return Colors.green;
      case 'BAJA':
        return Colors.orange;
      case 'ALTA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}