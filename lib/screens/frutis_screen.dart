import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Producto {
  final String id;
  final String nombre;
  final String imagen;
  final String prediccion;
  final Map<String, dynamic> timestamp;

  Producto({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.prediccion,
    required this.timestamp,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? '', 
      nombre: json['nombre'] ?? '',
      imagen: json['imagen'] ?? '',
      prediccion: json['prediccion'] ?? '',
      timestamp:
          json['timestamp'] is Map
              ? Map<String, dynamic>.from(json['timestamp'])
              : {},
    );
  }
}

Future<List<Producto>> fetchFrutasYVerduras() async {
  final response = await http.get(
    Uri.parse('https://frostback.onrender.com/appi/obtenerFrutasyV'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> frutasYVerdurasJson = data['FrutasyV'];

    // Imprimir cada JSON individual para depurar
    frutasYVerdurasJson.forEach((json) {
      //print('Producto JSON: $json');
    });

    return frutasYVerdurasJson
        .map((json) => Producto.fromJson(json))
        .toList();
  } else {
    throw Exception('Error al cargar frutas y verduras');
  }
}


Future<bool> eliminarProducto(String id) async {
  //print('ID enviado para eliminar: $id'); // Consola

  final response = await http.delete(
    Uri.parse('https://frostback.onrender.com/appi/eliminarFrutasyV/$id'),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
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
      title: 'Frutas y Verduras',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[50],

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.green.shade800),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.green.shade800,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      home: FrutasVerdurasScreen(),
    );
  }
}

class FrutasVerdurasScreen extends StatefulWidget {
  @override
  _FrutasVerdurasScreenState createState() => _FrutasVerdurasScreenState();
}

class _FrutasVerdurasScreenState extends State<FrutasVerdurasScreen> {
  late Future<List<Producto>> futureFrutasYVerduras;

  @override
  void initState() {
    super.initState();
    futureFrutasYVerduras = fetchFrutasYVerduras();
  }

  void _refreshData() {
    setState(() {
      futureFrutasYVerduras = fetchFrutasYVerduras();
    });
  }

  Future<void> _mostrarDialogoConfirmacionEliminar(Producto producto) async {
    // Verifica si el widget todavía está montado
    if (!mounted) return;

    final confirmacion = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('¿Estás seguro de que quieres eliminar'),
              Text(
                producto.nombre,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('de tu lista?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      try {
        final eliminado = await eliminarProducto(producto.id);
        if (eliminado && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${producto.nombre} eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Frutas y Verduras',
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
        future: futureFrutasYVerduras,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando frutas y verduras...',
                    style: GoogleFonts.poppins(color: Colors.green.shade800),
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
                      backgroundColor: Colors.green.shade800,
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
                    color: Colors.green.shade800,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay frutas ni verduras disponibles',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final productos = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: Colors.green.shade800,
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
    // Determinar si la fruta está podrida
    final bool estaPodrida = producto.prediccion.toLowerCase().contains(
      'podrida',
    );

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
          color: estaPodrida ? Colors.red : Colors.grey.withOpacity(0.2),
          width: estaPodrida ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              splashColor: Colors.green.shade100.withOpacity(0.3),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                                            (context, error, stackTrace) =>
                                                Icon(
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
                                  color:
                                      estaPodrida
                                          ? Colors.red
                                          : Colors.grey.shade800,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Estado: ${producto.prediccion}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color:
                                      estaPodrida
                                          ? Colors.red
                                          : Colors.grey.shade600,
                                  fontWeight:
                                      estaPodrida
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Fecha: ${DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.fromMillisecondsSinceEpoch(producto.timestamp['_seconds'] * 1000))}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Badge PODRIDA
          if (estaPodrida)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PODRIDA',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Botón de eliminar
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {                
                _mostrarDialogoConfirmacionEliminar(producto);
              },
            ),
          ),
        ],
      ),
    );
  }
}
