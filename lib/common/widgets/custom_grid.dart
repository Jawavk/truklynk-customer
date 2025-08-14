import 'package:flutter/material.dart';

import '../../pages/History/data/models/history_card_model.dart';

class CustomWrap extends StatelessWidget {
  final List<GridItemModel> items;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double spacing; // Spacing between items
  final double runSpacing; // Vertical spacing between rows
  final double? width; // Optional width for each item
  final double? height; // Optional height for each item

  const CustomWrap({
    super.key,
    required this.items,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.spacing = 10.0,
    this.runSpacing = 10.0,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = width ?? (screenWidth - (spacing * 2)) / 2; // Default to 2 items per row
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items.map((item) {
        return GestureDetector(
          onTap: item.onTap,
          child: Container(
            width: itemWidth,
            height: height,
            margin: item.margin ?? EdgeInsets.zero,
            padding: item.padding ?? EdgeInsets.zero,
            decoration: BoxDecoration(
              color: item.backgroundColor ?? Colors.white,
              borderRadius: item.borderRadius ?? BorderRadius.circular(10),
            ),
            child: item.widget,
          ),
        );
      }).toList(),
    );
  }
}
