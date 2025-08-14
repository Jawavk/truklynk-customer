import 'package:flutter/material.dart';

class CustomDecorations {
  static BoxDecoration customBoxDecoration({
    required Color color,
    Gradient? gradient,
    Border? border,
    double borderRadius = 0.0,
    Color shadowColor = Colors.transparent,
    double blurRadius = 0.0,
    double spreadRadius = 0.0, // Add this line
    Offset offset = Offset.zero,
  }) {
    return BoxDecoration(
      color: gradient == null ? color : null, // Use color only if no gradient
      gradient: gradient,
      border: border,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius, // Use spreadRadius here
          offset: offset,
        ),
      ],
    );
  }
}
