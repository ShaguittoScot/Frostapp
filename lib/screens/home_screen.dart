import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frost_/widgets/category_item.dart';
import 'inventory_screen.dart';
import 'recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double temperatura = 0.0;
  double humedad = 0.0;

  @override
  void initState() {
    super.initState();
    _actualizarSensores();
  }

  void _actualizarSensores() {
    setState(() {
      // Simulación de valores (en un futuro, estos datos vendrían de un sensor)
      temperatura = 3.0 + Random().nextDouble() * 3; // Entre 3°C y 6°C
      humedad = 70 + Random().nextDouble() * 20; // Entre 70% y 90%
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Bienvenida con icono
            Row(
              children: [
                // Sección de bienvenida
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 40, color: Colors.deepOrange),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "¡Hola!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Sección del refrigerador - Versión ultra compacta
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.kitchen,
                                size: 16,
                                color: Colors.blue[800],
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Refri",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              _buildTempChip(temperatura),
                              SizedBox(width: 4),
                              _buildHumidityChip(humedad),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 6),
                      GestureDetector(
                        onTap: _actualizarSensores,
                        child: Icon(
                          Icons.refresh,
                          size: 18,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Botones de acciones rápidas
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount =
                    constraints.maxWidth > 600
                        ? 4
                        : 2; // Cambiar el número de columnas en función del tamaño de la pantalla
                return GridView.count(
                  crossAxisCount: crossAxisCount, // Número de columnas
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // Deshabilita el scroll interno
                  childAspectRatio: 1.0,
                  children: [
                    CategoryItem(
                      icon: ('assets/icons/scanner.svg'),
                      color: Colors.green,
                      label: "Escanear",
                      onTap: () {
                        Fluttertoast.showToast(
                          msg: "Escanear",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      },
                    ),
                    CategoryItem(
                      icon: ('assets/icons/book-bookmark.svg'),
                      color: Colors.purple,
                      label: "Recetas",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecetasScreen(),
                          ),
                        );
                        Fluttertoast.showToast(
                          msg: "Recetas",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      },
                    ),
                    CategoryItem(
                      icon: ('assets/icons/fridge.svg'),
                      color: Colors.blue,
                      label: "Inventario",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventarioScreen(),
                          ),
                        );
                        Fluttertoast.showToast(
                          msg: "Inventario",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      },
                    ),
                    CategoryItem(
                      icon: ('assets/icons/info-circle.svg'),
                      color: Colors.red,
                      label: "Próximos a vencer",
                      onTap: () {
                        Fluttertoast.showToast(
                          msg: "Próximos a vencer",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

Widget _buildHumidityChip(double hum) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.water_drop, size: 14, color: Colors.blue[700]),
        SizedBox(width: 2),
        Text(
          "${hum.toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTempChip(double temp) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.thermostat, size: 14, color: Colors.red[700]),
        SizedBox(width: 2),
        Text(
          "${temp.toStringAsFixed(1)}°",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.red[800],
          ),
        ),
      ],
    ),
  );
}
