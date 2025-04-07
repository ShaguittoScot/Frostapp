import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'recipeDetails_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Montserrat',
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: RecetasScreen(),
    );
  }
}

class RecetasScreen extends StatefulWidget {
  @override
  _RecetasScreenState createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> {
  late Future<List<String>> _ingredientesFuture;
  List<String> _todosIngredientes = [];
  List<String> _ingredientesSeleccionados = [];
  bool _loadingRecetas = false;
  List<dynamic> _recetas = [];
  final ScrollController _scrollController = ScrollController();
  bool _showIngredients = true;

  @override
  void initState() {
    super.initState();
    _ingredientesFuture = _fetchIngredientes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showIngredients) {
        setState(() => _showIngredients = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showIngredients && _scrollController.offset <= 100) {
        setState(() => _showIngredients = true);
      }
    }
  }

  Future<List<String>> _fetchIngredientes() async {
    final response = await http.get(
      Uri.parse('https://frostback.onrender.com/appi/listaProductos'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final productos = data['productos'] as List;

      return productos
          .map<String>(
            (producto) => producto['nombre'].toString().toLowerCase(),
          )
          .toSet()
          .toList();
    } else {
      throw Exception('Error al cargar los ingredientes');
    }
  }

  Future<void> _fetchRecetas() async {
    if (_ingredientesSeleccionados.isEmpty) {
      setState(() => _recetas = []);
      return;
    }

    setState(() => _loadingRecetas = true);

    try {
      final ingredientesQuery = _ingredientesSeleccionados.join(',');
      final response = await http.get(
        Uri.parse(
          'https://frostback.onrender.com/appi/recetas?ingredientes=$ingredientesQuery',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _recetas = data["recetas"] ?? []);
      } else {
        throw Exception('Error al cargar las recetas');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _loadingRecetas = false);
    }
  }

  void _toggleIngrediente(String ingrediente, bool seleccionado) {
    setState(() {
      seleccionado
          ? _ingredientesSeleccionados.add(ingrediente)
          : _ingredientesSeleccionados.remove(ingrediente);
    });
    _fetchRecetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<String>>(
        future: _ingredientesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator('Cargando ingredientes...');
          } else if (snapshot.hasError) {
            return _buildErrorWidget();
          } else if (snapshot.hasData) {
            _todosIngredientes = snapshot.data!;
            return _buildMainContent();
          } else {
            return Center(child: Text('No se encontraron ingredientes'));
          }
        },
      ),
    );
  }

  // Reemplaza _buildMainContent() con este código:
  Widget _buildMainContent() {
    return CustomScrollView(
      controller: _scrollController,
      physics: ClampingScrollPhysics(),
      slivers: [
        SliverAppBar(
          title: Text(
            'Recetas Deliciosas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.orange[600],
          elevation: 4,
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          pinned: true,
          floating: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _ingredientesFuture = _fetchIngredientes();
                  _recetas = [];
                });
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: ExpansionTile(
            title: Text(
              'Ingredientes disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            subtitle: Text(
              '${_ingredientesSeleccionados.length} seleccionados',
              style: TextStyle(color: Colors.orange),
            ),
            initiallyExpanded: true,
            children: [_buildIngredientesList(), SizedBox(height: 8)],
          ),
        ),
        _buildRecetasSliverList(),
      ],
    );
  }


  Widget _buildIngredientesList() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _todosIngredientes.length,
        padding: EdgeInsets.symmetric(horizontal: 8),
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final ingrediente = _todosIngredientes[index];
          final estaSeleccionado = _ingredientesSeleccionados.contains(
            ingrediente,
          );

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _toggleIngrediente(ingrediente, !estaSeleccionado),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        estaSeleccionado ? 0.15 : 0.03,
                      ),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                  gradient:
                      estaSeleccionado
                          ? LinearGradient(
                            colors: [Colors.orange[600]!, Colors.orange[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : LinearGradient(
                            colors: [Colors.white, Colors.grey[100]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                  border: Border.all(
                    color:
                        estaSeleccionado
                            ? Colors.orange[300]!
                            : Colors.grey[300]!,
                    width: estaSeleccionado ? 1.2 : 0.8,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (estaSeleccionado)
                      Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      ingrediente,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            estaSeleccionado
                                ? FontWeight.w600
                                : FontWeight.w500,
                        color:
                            estaSeleccionado ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecetasSliverList() {
    if (_loadingRecetas) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              SizedBox(height: 20),
              Text(
                'Buscando recetas...',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    } else if (_ingredientesSeleccionados.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 60, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Selecciona ingredientes',
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              Text(
                'para buscar recetas',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    } else if (_recetas.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fastfood, size: 60, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'No hay recetas disponibles',
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              Text(
                'para los ingredientes seleccionados',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final receta = _recetas[index];
        return _buildRecipeCard(receta);
      }, childCount: _recetas.length),
    );
  }

  Widget _buildRecipeCard(dynamic receta) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleRecetaScreen(receta: receta),
            ),
          ),
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Hero(
                tag: 'receta-image-${receta['id']}',
                child: Image.network(
                  receta['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receta['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 18),
                          SizedBox(width: 5),
                          Text(
                            '${receta['likes']} likes',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Ver receta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 20),
          Text(
            'Error al cargar ingredientes',
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed:
                () =>
                    setState(() => _ingredientesFuture = _fetchIngredientes()),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class DetalleRecetaScreen extends StatelessWidget {
  final Map<String, dynamic> receta;

  DetalleRecetaScreen({required this.receta});

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
                        // Imagen de fondo que ocupa todo el espacio
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                          ),
                          child: Container(
                            color:
                                Colors
                                    .grey[100], // Color de fondo mientras carga
                            child: Hero(
                              tag: 'receta-image-${receta['id']}',
                              child: Image.network(
                                receta['image'],
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
                                        Colors.orangeAccent,
                                      ),
                                      strokeWidth: 3,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.fastfood_rounded,
                                            size: 60,
                                            color: Colors.orangeAccent
                                                .withOpacity(0.5),
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
                      receta['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2, // Mostrar máximo 2 líneas
                      overflow:
                          TextOverflow.ellipsis, // Puntos suspensivos si excede
                      textAlign: TextAlign.center, // Centrar el texto
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Tarjetas de estadísticas
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
                          value: '${receta['likes']}',
                          label: 'Likes',
                          color: Colors.red[400]!,
                        ),
                        _buildStatCard(
                          icon: Icons.check_circle,
                          value: '${receta['usedIngredients'].length}',
                          label: 'Disponibles',
                          color: Colors.green[400]!,
                        ),
                        _buildStatCard(
                          icon: Icons.warning,
                          value: '${receta['missedIngredients'].length}',
                          label: 'Faltantes',
                          color: Colors.orange[400]!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Ingredientes disponibles
                  _buildSectionHeader(
                    title: 'Ingredientes disponibles',
                    icon: Icons.check_circle,
                    color: Colors.green[400]!,
                  ),
                  const SizedBox(height: 15),
                  ...receta['usedIngredients']
                      .map<Widget>(
                        (ing) => _buildIngredientCard(
                          ingredient: ing,
                          isAvailable: true,
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 30),

                  // Ingredientes faltantes
                  _buildSectionHeader(
                    title: 'Ingredientes faltantes',
                    icon: Icons.warning,
                    color: Colors.orange[400]!,
                  ),
                  const SizedBox(height: 15),
                  ...receta['missedIngredients']
                      .map<Widget>(
                        (ing) => _buildIngredientCard(
                          ingredient: ing,
                          isAvailable: false,
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 40),

                  // Botón de instrucciones
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        elevation: 5,
                        shadowColor: Colors.orange.withOpacity(0.2),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => InstruccionesRecetaScreen(
                                  recetaId: receta['id'],
                                  heroTag: 'receta-image-${receta['id']}',
                                ),
                          ),
                        );
                      },
                      child: const Text(
                        'Ver instrucciones completas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para tarjetas de estadísticas
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Widget auxiliar para encabezados de sección
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para tarjetas de ingredientes
  Widget _buildIngredientCard({
    required Map<String, dynamic> ingredient,
    required bool isAvailable,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey[100],
              child: Image.network(
                ingredient['image'],
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.kitchen,
                        size: 30,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),
          ),
          title: Text(
            ingredient['original'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isAvailable ? Colors.grey[800] : Colors.red[600],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable ? Icons.check : Icons.close,
              color: isAvailable ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
