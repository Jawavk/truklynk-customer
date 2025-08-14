import 'dart:ui';

import 'package:flutter/material.dart';

class DottedLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    for (int i = 0; i < size.width.toInt(); i += 10) {
      canvas.drawCircle(
        Offset(i.toDouble(), size.height.toInt() / 2),
        1, // Change this value to adjust the size of the dots
        paint,
      );
      if (i < size.width.toInt() - 10) {
        canvas.drawLine(
          Offset(i.toDouble() + 2, size.height.toInt() / 2),
          Offset(i.toDouble() + 8, size.height.toInt() / 2),
          Paint()
            ..color = Colors.black
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}