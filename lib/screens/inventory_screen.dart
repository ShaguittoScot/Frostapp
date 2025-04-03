import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// Clase Producto con el nuevo campo "imagen"
class Producto {
  final String codigoBarras;
  final String categoria;
  final String imagen;
  final String nombre;
  final String fechaCaducidad;
  final String marca;

  Producto({
    required this.codigoBarras,
    required this.categoria,
    required this.imagen,
    required this.nombre,
    required this.fechaCaducidad,
    required this.marca,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      codigoBarras: json['codigo_barras'],
      categoria: json['categoria'],
      imagen:
          json['imagen'] ?? "", // Manejo de nulo en caso de que no haya imagen
      nombre: json['nombre'],
      fechaCaducidad: json['fecha_caducidad'],
      marca: json['marca'],
    );
  }
}

// Función para obtener el inventario de la API
Future<List<Producto>> fetchInventario() async {
  final response = await http.get(
    Uri.parse('https://frostback.onrender.com/appi/inventario'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> productosJson = data['Productos'];
    return productosJson.map((json) => Producto.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar el inventario');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Inventario', home: InventarioScreen());
  }
}

class InventarioScreen extends StatefulWidget {
  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  late Future<List<Producto>> futureInventario;

  @override
  void initState() {
    super.initState();
    futureInventario = fetchInventario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: FutureBuilder<List<Producto>>(
          future: futureInventario,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Cargando inventario...',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error al cargar los datos',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Aquí puedes agregar lógica para reintentar
                      },
                      child: Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 60,
                      color: Colors.blue.shade800,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Inventario Vacío',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay productos disponibles',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Aquí puedes agregar lógica para agregar nuevos productos
                      },
                      child: Text('Agregar Producto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final productos = snapshot.data!;

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // Acción al tocar el producto
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen del producto con bordes redondeados y animación Hero
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Hero(
                                tag:
                                    'producto_${producto.nombre}', // Para animaciones
                                child: Container(
                                  width: 110,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                  ),
                                  child:
                                      producto.imagen.isNotEmpty
                                          ? Image.network(
                                            producto.imagen,
                                            width: 110,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                          )
                                          : Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.grey.shade400,
                                          ),
                                ),
                              ),
                            ),

                            SizedBox(width: 16),

                            // Detalles del producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre del producto con mejor tipografía
                                  Text(
                                    producto.nombre,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: 6),

                                  // Marca con estilo más moderno
                                  Text(
                                    producto.marca,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),

                                  SizedBox(height: 10),

                                  // Categoría con mejor icono y espaciado
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.category,
                                        size: 18,
                                        color: Colors.grey.shade500,
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          producto.categoria,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 8),

                                  // Fecha de caducidad con icono moderno
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        size: 18,
                                        color: Colors.grey.shade500,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Cad: ${producto.fechaCaducidad}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Botón de opciones con efecto táctil
                            IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                size: 22,
                                color: Colors.grey.shade500,
                              ),
                              onPressed: () {
                                // Mostrar opciones adicionales
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );

              
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para agregar nuevo producto
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
      ),
    );
  }
}
