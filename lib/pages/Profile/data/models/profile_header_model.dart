import 'package:flutter/material.dart';

class HeaderItem {
  final Widget? widget;
  final Color? color;
  final Color? backgroundColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isCenter;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Function()? onTap;
  final bool isExpanded;


  HeaderItem({
    this.widget,
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.onTap,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isCenter = false,
    required this.isExpanded,
  });
}

class GridItemModel {
  final Widget? widget;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  GridItemModel({
    this.widget,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
  });
}
