import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashHeight;
  final double space;
  final Color color;

  const DashedDivider({
    super.key,
    this.dashWidth = 8.0,
    this.dashHeight = 1.0,
    this.space = 4.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedLinePainter(
        dashWidth: dashWidth,
        dashHeight: dashHeight,
        space: space,
        color: color,
      ),
      child: Container(),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashHeight;
  final double space;
  final Color color;

  DashedLinePainter({
    required this.dashWidth,
    required this.dashHeight,
    required this.space,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = dashHeight;

    double startX = 0;

    while (startX < size.width) {
      final endX = startX + dashWidth;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(endX, 0),
        paint,
      );
      startX = endX + space;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
