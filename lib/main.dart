import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frost_/screens/home_screen.dart';
import 'package:frost_/screens/login_screen.dart';
import 'package:frost_/screens/settings_screen.dart';
//import 'package:frost_/screens/scaner_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isLoggedIn = await checkLoginStatus();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkLoginStatus() async {
  final storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'session_cookie'); // Lee el token guardado
  return token != null; // Si hay un token, el usuario está logeado
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refrigerador App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color.fromARGB(255, 33, 33, 33),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 33, 33, 33),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 33, 33, 33),
        ),
      ),
      home: isLoggedIn ? MainScreen() : LoginScreen(), // Verifica sesión
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    //ScannerScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Función para manejar iconos SVG con cambio de color dinámico
  Widget _buildSvgIcon(String assetName, int index) {
    return SvgPicture.asset(
      assetName,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        _selectedIndex == index ? Colors.blue : Colors.white,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black, // Color de fondo
            borderRadius: BorderRadius.circular(10),

          ), 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child:
                _widgetOptions[_selectedIndex], // Muestra la pantalla seleccionada
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildSvgIcon('assets/icons/home.svg', 0),
            label: 'Inicio',
            activeIcon: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildSvgIcon('assets/icons/home.svg', 0),
            ),
          ),
          /*BottomNavigationBarItem(
            icon: _buildSvgIcon('assets/icons/scanner.svg', 1),
            label: 'Escáner',
            activeIcon: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildSvgIcon('assets/icons/scanner.svg', 1),
            ),
          ),*/
          BottomNavigationBarItem(
            icon: _buildSvgIcon('assets/icons/settings.svg', 1),
            label: 'Configuración',
            activeIcon: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildSvgIcon('assets/icons/settings.svg', 1),
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}
