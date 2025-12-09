import 'package:flutter/material.dart';

class TreasureChestIcon extends StatelessWidget {
  const TreasureChestIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.black87,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TreasureChestPainter(color: color),
      ),
    );
  }
}

class _TreasureChestPainter extends CustomPainter {
  _TreasureChestPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.5;

    // Coffre (marron foncé)
    paint.color = const Color(0xFF8B4513);
    
    // Corps du coffre
    final chestRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.35, size.width * 0.8, size.height * 0.55),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(chestRect, paint);

    // Couvercle du coffre (légèrement ouvert)
    paint.color = const Color(0xFF654321);
    final lidPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.4)
      ..lineTo(size.width * 0.15, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.15)
      ..lineTo(size.width * 0.9, size.height * 0.4)
      ..close();
    canvas.drawPath(lidPath, paint);

    // Bordure dorée du coffre
    paint.color = const Color(0xFFFFD700);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.05;
    canvas.drawRRect(chestRect, paint);

    // Serrure dorée
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.6),
      size.width * 0.08,
      paint,
    );

    // Pièces d'or qui brillent au-dessus
    paint.color = const Color(0xFFFFD700);
    
    // Pièce 1
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.25),
      size.width * 0.08,
      paint,
    );
    
    // Pièce 2
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.09,
      paint,
    );
    
    // Pièce 3
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.28),
      size.width * 0.07,
      paint,
    );

    // Reflets sur les pièces (blanc)
    paint.color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(
      Offset(size.width * 0.32, size.height * 0.23),
      size.width * 0.03,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.18),
      size.width * 0.035,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.26),
      size.width * 0.025,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
