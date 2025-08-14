import 'package:flutter/material.dart';
import 'decoration.dart'; // Assuming you have your custom decoration logic in this file

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Border? border;
  final Gradient? gradient;
  final Clip clipBehavior;
  final double? width;
  final double? height;
  final String? appBarTitle; // Optional title for the AppBar

  CustomCard({
    required this.child,
    this.color = Colors.white,
    this.elevation = 4.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.border,
    this.gradient,
    this.clipBehavior = Clip.hardEdge,
    this.width,
    this.height,
    this.appBarTitle, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: CustomDecorations.customBoxDecoration(
        color: color,
        gradient: gradient,
        border: border,
        borderRadius: 12.0,
        shadowColor: Colors.black.withOpacity(0.5),
        blurRadius: elevation,
        offset: Offset(0, 2),
      ),
      padding: padding,
      child: Column(
        children: [
          if (appBarTitle != null)
            AppBar(
              title: Text(appBarTitle!),
              backgroundColor: color,
              elevation: 0,
            ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              clipBehavior: clipBehavior,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
