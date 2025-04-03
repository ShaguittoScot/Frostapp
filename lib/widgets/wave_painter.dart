import 'package:flutter/material.dart';
import 'dart:math'; // Para usar Random en los detalles de condensación

class FridgeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fondo con un degradado de tonos azules oscuros pegando al negro
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.shade900,
          Colors.black,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    // Pequeños detalles que simulan condensación o frescura
    final Paint condensationPaint = Paint()
      ..color = Colors.blue.shade200.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Random random = Random();
    for (int i = 0; i < 50; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double radius = random.nextDouble() * 5 + 2;
      canvas.drawCircle(Offset(x, y), radius, condensationPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}