import 'package:flutter/material.dart';
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
  _InstruccionesRecetaScreenState createState() => _InstruccionesRecetaScreenState();
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
      Uri.parse('https://frostback.onrender.com/appi/recetabusc/${widget.recetaId}'),
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
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: widget.heroTag,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Image.network(
                      _recetaData?['image'] ?? '',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.fastfood,
                          size: 60,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                _recetaData?['title'] ?? 'Receta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resto del contenido permanece igual
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              backgroundColor: Colors.orange[100],
                              label: Text(
                                '${_recetaData!['aggregateLikes']} likes',
                                style: TextStyle(color: Colors.orange[800]),
                              ),
                              avatar: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Chip(
                              backgroundColor: Colors.green[100],
                              label: Text(
                                '${_recetaData!['readyInMinutes']} min',
                                style: TextStyle(color: Colors.green[800]),
                              ),
                              avatar: Icon(
                                Icons.timer,
                                color: Colors.green,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Chip(
                              backgroundColor: Colors.blue[100],
                              label: Text(
                                '${_recetaData!['servings']} porciones',
                                style: TextStyle(color: Colors.blue[800]),
                              ),
                              avatar: Icon(
                                Icons.people,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sección de ingredientes
                        _buildSectionTitle('Ingredientes', Colors.orange[800]!),
                        const SizedBox(height: 12),
                        _buildIngredientsList(),
                        const SizedBox(height: 24),

                        // Sección de instrucciones
                        _buildSectionTitle('Instrucciones', Colors.orange[800]!),
                        const SizedBox(height: 12),
                        _buildInstructions(),
                        const SizedBox(height: 24),

                        // Información adicional
                        _buildSectionTitle('Información Adicional', Colors.orange[800]!),
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
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
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
        children: _recetaData!['extendedIngredients']
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
          children: _recetaData!['analyzedInstructions'][0]['steps']
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
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}