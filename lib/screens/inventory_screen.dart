import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Producto {
  final String id;
  final String codigoBarras;
  final String categoria;
  final String imagen;
  final String nombre;
  final String fechaCaducidad;
  final String marca;

  Producto({
    required this.id,
    required this.codigoBarras,
    required this.categoria,
    required this.imagen,
    required this.nombre,
    required this.fechaCaducidad,
    required this.marca,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      codigoBarras: json['codigo_barras'],
      categoria: json['categoria'],
      imagen: json['imagen'] ?? "",
      nombre: json['nombre'],
      fechaCaducidad: json['fecha_caducidad'],
      marca: json['marca'],
    );
  }
}

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

Future<void> deleteProducto(String id) async {
  try {
    // Imprime el ID que se está enviando
    //print('ID del producto a eliminar: $id');

    final response = await http.delete(
      Uri.parse('https://frostback.onrender.com/appi/eliminarProducto/$id'),
    );

    //print('Código de estado: ${response.statusCode}');
    //print('Cuerpo de la respuesta: ${response.body}');

    if (response.statusCode == 200) {
      //print('Producto eliminado correctamente');
    } else {
      //print('Error al eliminar el producto');
      throw Exception('Error al eliminar el producto');
    }
  } catch (e) {
    //print('Error al realizar la solicitud: $e');
    throw Exception('Error al eliminar el producto');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.blue.shade800),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.blue.shade800,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: InventarioScreen(),
    );
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

  void _refreshData() {
    setState(() {
      futureInventario = fetchInventario();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(
          'Inventario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        elevation: 4,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<Producto>>(
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
                    style: GoogleFonts.poppins(color: Colors.blue.shade800),
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
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
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
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No hay productos disponibles',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para agregar nuevo producto
                    },
                    child: Text('Agregar Producto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final productos = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: Colors.blue.shade800,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return _buildProductCard(producto);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProductCard(Producto producto) {
    DateTime fechaActual = DateTime.now();
    DateTime fechaCaducidad =
        DateTime.tryParse(producto.fechaCaducidad) ?? fechaActual;
    bool estaCaducado = fechaCaducidad.isBefore(fechaActual);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: estaCaducado ? Colors.redAccent : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Acción al tocar el producto
          },
          splashColor: Colors.blue.shade100.withOpacity(0.3),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto
                Hero(
                  tag: 'producto_${producto.nombre}',
                  child: Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        producto.imagen.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                producto.imagen,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                              ),
                            )
                            : Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                  ),
                ),
                SizedBox(width: 16),
                // Detalles del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        producto.marca,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              producto.categoria,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Cad: ${producto.fechaCaducidad}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  estaCaducado
                                      ? Colors.redAccent
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 22,
                    color: Colors.red.shade600,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('¿Eliminar producto?'),
                            content: Text(
                              '¿Estás seguro de que deseas eliminar "${producto.nombre}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      try {
                        await deleteProducto(producto.id);
                        _refreshData(); // Actualizar inventario
                      } catch (e) {
                        //print('Error al eliminar el producto: $e');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
