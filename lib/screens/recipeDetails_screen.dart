import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InstruccionesRecetaScreen extends StatefulWidget {
  final int recetaId;
  final String heroTag;

  const InstruccionesRecetaScreen({
    Key? key,
    required this.recetaId,
    required this.heroTag,
  }) : super(key: key);

  @override
  _InstruccionesRecetaScreenState createState() =>
      _InstruccionesRecetaScreenState();
}

class _InstruccionesRecetaScreenState extends State<InstruccionesRecetaScreen> {
  late Future<Map<String, dynamic>> _recetaDetalles;
  bool _isLoading = true;
  Map<String, dynamic>? _recetaData;

  @override
  void initState() {
    super.initState();
    _recetaDetalles = _fetchRecetaDetalles();
  }

  Future<Map<String, dynamic>> _fetchRecetaDetalles() async {
    final response = await http.get(
      Uri.parse(
        'https://frostback.onrender.com/appi/recetabusc/${widget.recetaId}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _recetaData = data['receta'];
        _isLoading = false;
      });
      return data;
    } else {
      throw Exception('Error al cargar los detalles de la receta');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  background: SizedBox.expand(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                          ),
                          child: Hero(
                            tag: widget.heroTag,
                            child: Image.network(
                              _recetaData?['image'] ?? '',
                              fit: BoxFit.cover,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orange,
                                    ),
                                    strokeWidth: 3,
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey[100],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.fastfood_rounded,
                                            size: 60,
                                            color: Colors.orange.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Imagen no disponible',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        // Overlay con gradiente
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                                stops: [0.6, 1.0],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                              ),
                            ),
                          ),
                        ),

                        // Efecto de desenfoque en los bordes
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 0.5,
                                sigmaY: 0.5,
                              ),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _recetaData?['title'] ?? 'Receta',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 0),
                );
              },
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                        
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  icon: Icons.favorite,
                                  value: '${_recetaData!['aggregateLikes']}',
                                  label: 'Likes',
                                  color: Colors.red[400]!,
                                ),
                                _buildStatCard(
                                  icon: Icons.timer,
                                  value: '${_recetaData!['readyInMinutes']}',
                                  label: 'Minutos',
                                  color: Colors.green[400]!,
                                ),
                                _buildStatCard(
                                  icon: Icons.people,
                                  value: '${_recetaData!['servings']}',
                                  label: 'Porciones',
                                  color: Colors.blue[400]!,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sección de ingredientes
                          _buildSectionTitle(
                            'Ingredientes',
                            Colors.orange[800]!,
                          ),
                          const SizedBox(height: 12),
                          _buildIngredientsList(),
                          const SizedBox(height: 24),

                          // Sección de instrucciones
                          _buildSectionTitle(
                            'Instrucciones',
                            Colors.orange[800]!,
                          ),
                          const SizedBox(height: 12),
                          _buildInstructions(),
                          const SizedBox(height: 24),

                          // Información adicional
                          _buildSectionTitle(
                            'Información Adicional',
                            Colors.orange[800]!,
                          ),
                          const SizedBox(height: 12),
                          _buildAdditionalInfo(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  // Los métodos auxiliares (_buildSectionTitle, _buildIngredientsList, etc.)
  // permanecen exactamente iguales que en tu código original
  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildIngredientsList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children:
            _recetaData!['extendedIngredients']
                .map<Widget>(
                  (ing) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ing['original'],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildInstructions() {
    if (_recetaData!['analyzedInstructions'] != null &&
        _recetaData!['analyzedInstructions'].isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children:
              _recetaData!['analyzedInstructions'][0]['steps']
                  .map<Widget>(
                    (step) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.orange[700],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              step['number'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step['step'],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          _recetaData!['instructions'] ?? 'No hay instrucciones disponibles',
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      );
    }
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRowItem(
            'Tipo de plato:',
            _recetaData!['dishTypes']?.join(', ') ?? 'No especificado',
          ),
          const SizedBox(height: 8),
          _buildInfoRowItem(
            'Cocina:',
            _recetaData!['cuisines']?.join(', ') ?? 'No especificada',
          ),
          const SizedBox(height: 8),
          _buildInfoRowItem(
            'Vegetariano:',
            _recetaData!['vegetarian'] == true ? 'Sí' : 'No',
          ),
          const SizedBox(height: 8),
          _buildInfoRowItem(
            'Vegano:',
            _recetaData!['vegan'] == true ? 'Sí' : 'No',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

Widget _buildStatCard({
  required IconData icon,
  required String value,
  required String label,
  required Color color,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 28, color: color),
      const SizedBox(height: 6),
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
      ),
    ],
  );
}
