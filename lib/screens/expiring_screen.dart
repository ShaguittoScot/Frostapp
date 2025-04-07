import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpiringInventoryScreen extends StatefulWidget {
  @override
  _ExpiringInventoryScreenState createState() =>
      _ExpiringInventoryScreenState();
}

class _ExpiringInventoryScreenState extends State<ExpiringInventoryScreen> {
  List<dynamic> products = [];
  List<dynamic> fruitsAndVeggies = [];
  bool _isLoading = true;
  final PageController _fruitsController = PageController(
    viewportFraction: 0.4,
  );
  final PageController _productsController = PageController(
    viewportFraction: 0.4,
  );

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final productsResp = await http.get(
        Uri.parse('https://frostback.onrender.com/appi/inventario'),
      );
      final fruitsResp = await http.get(
        Uri.parse('https://frostback.onrender.com/appi/obtenerFrutasyV'),
      );

      if (productsResp.statusCode == 200 && fruitsResp.statusCode == 200) {
        setState(() {
          products = json.decode(productsResp.body)['Productos'];
          fruitsAndVeggies = json.decode(fruitsResp.body)['FrutasyV'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar los datos: $e')));
    }
  }

  List<dynamic> filterByExpiration(int days) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: days));
    return products.where((p) {
      final expirationDate = DateTime.parse(p['fecha_caducidad']);
      return expirationDate.isAfter(now) && expirationDate.isBefore(limit);
    }).toList();
  }

  List<dynamic> filterByExpirationRange(int fromDays, int toDays) {
    final now = DateTime.now();
    final from = now.add(Duration(days: fromDays));
    final to = now.add(Duration(days: toDays));
    return products.where((p) {
      final expirationDate = DateTime.parse(p['fecha_caducidad']);
      return expirationDate.isAfter(from) && expirationDate.isBefore(to);
    }).toList();
  }

  List<dynamic> fruitsByState(String state) {
    return fruitsAndVeggies.where((f) => f['estado'] == state).toList();
  }

  Widget buildHorizontalProductsList(
    List<dynamic> items,
    String title,
    Color titleColor,
  ) {
    if (items.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
        SizedBox(
          height: 300, 
          child: PageView.builder(
            controller: _productsController,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return buildSquareProductCard(items[index], context);
            },
            padEnds: false,
          ),
        ),
      ],
    );
  }

  Widget buildSquareProductCard(Map product, BuildContext context) {
    final expirationDate = DateTime.parse(product['fecha_caducidad']);
    final daysLeft = expirationDate.difference(DateTime.now()).inDays;
    Color expirationColor;
    String expirationText;

    if (daysLeft <= 7) {
      expirationColor = Colors.red[700]!;
      expirationText = 'PRONTO A VENCER';
    } else if (daysLeft <= 15) {
      expirationColor = Colors.orange[700]!;
      expirationText = 'VENCE PRONTO';
    } else {
      expirationColor = Colors.green[700]!;
      expirationText = 'EN TIEMPO';
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.38,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['imagen'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.shopping_basket,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                product['nombre'] ?? 'Producto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),

              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 4),
                  Text(
                    '$daysLeft días',
                    style: TextStyle(color: Colors.grey[800], fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: expirationColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: expirationColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    expirationText,
                    style: TextStyle(
                      color: expirationColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHorizontalFruitsList(List<dynamic> items, String title) {
    if (items.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        SizedBox(
          height: 220, 
          child: PageView.builder(
            controller: _fruitsController,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return buildSquareFruitCard(items[index], context);
            },
            padEnds: false,
          ),
        ),
      ],
    );
  }

  Widget buildSquareFruitCard(Map fruit, BuildContext context) {
    Color stateColor;
    String stateText;

    switch (fruit['estado']) {
      case 'fresca':
        stateColor = Colors.green[700]!;
        stateText = 'FRESCA';
        break;
      case 'madura':
        stateColor = Colors.orange[700]!;
        stateText = 'MADURA';
        break;
      case 'podrida':
        stateColor = Colors.red[700]!;
        stateText = 'PODRIDA';
        break;
      default:
        stateColor = Colors.grey;
        stateText = 'DESCONOCIDO';
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.38,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fruit['imagen'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                fruit['nombre'] ?? 'Fruta/Verdura',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: stateColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    stateText,
                    style: TextStyle(
                      color: stateColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (fruit['observaciones'] != null) ...[
                SizedBox(height: 8),
                Text(
                  fruit['observaciones'],
                  style: TextStyle(color: Colors.grey[800], fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
appBar: AppBar(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(20), 
    ),
  ),
  title: Text(
    "Inventario Próximo a Vencer",
    style: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.red.shade800,
  elevation: 1,
  centerTitle: true,
  iconTheme: IconThemeData(color: Colors.white),
),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchData,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de productos con carrusel
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          "Productos en Inventario",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                      buildHorizontalProductsList(
                        filterByExpiration(7),
                        "Vencen en 7 días",
                        Colors.red[700]!,
                      ),
                      buildHorizontalProductsList(
                        filterByExpirationRange(8, 15),
                        "Vencen entre 8 y 15 días",
                        Colors.orange[700]!,
                      ),
                      buildHorizontalProductsList(
                        filterByExpirationRange(15, 30),
                        "Vencen entre 15 y 30días",
                        Colors.blue[700]!,
                      ),

                      // Sección de frutas y verduras con carrusel
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 24),
                        child: Text(
                          "Frutas y Verduras",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                      buildHorizontalFruitsList(
                        fruitsByState("fresca"),
                        "Frescas",
                      ),
                      buildHorizontalFruitsList(
                        fruitsByState("madura"),
                        "Maduras",
                      ),
                      buildHorizontalFruitsList(
                        fruitsByState("podrida"),
                        "Podridas",
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }
}
