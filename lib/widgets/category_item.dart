import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



Widget _buildSvgIcon(String icon , Color color) {
    return SvgPicture.asset(
      icon,
      width: 44,
      height: 44,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

class CategoryItem extends StatelessWidget {
  final String icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const CategoryItem({super.key, 
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(10), // Margen alrededor del contenedor
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ), // Bordes redondeados
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Sombra suave
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 2), // Dirección de la sombra
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15), // Espacio alrededor del ícono
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), // Fondo del ícono
                shape: BoxShape.circle, // Forma circular
              ),
              child: _buildSvgIcon(icon,color), // Ícono
            ),
            SizedBox(height: 15), // Espacio entre el ícono y el texto
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Texto oscuro
              ),
            ),
          ],
        ),
      ),
    );
  }
}
