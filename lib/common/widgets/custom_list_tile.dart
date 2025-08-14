import 'package:flutter/material.dart';
import 'package:truklynk/common/models/header_model.dart';

class CustomListTile extends StatelessWidget {
  final HeaderItem? leading;
  final HeaderItem? title;
  final HeaderItem? trailing;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BorderSide? borderBottom;
  final Function()? onTap;

  const CustomListTile(
      {super.key,
      this.leading,
      this.title,
      this.trailing,
      this.backgroundColor,
      this.padding,
      this.margin,
      this.borderRadius,
      this.borderBottom,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(0),
          border: borderBottom != null
              ? Border(
                  bottom: borderBottom!,
                )
              : null,
        ),
        padding: padding ?? EdgeInsets.zero,
        margin: margin ?? EdgeInsets.zero,
        child: Row(
          children: [
            if (leading != null) _wrapWithExpanded(leading),
            if (title != null) _wrapWithExpanded(title),
            if (trailing != null) _wrapWithExpanded(trailing),
          ],
        ),
      ),
    );
  }

  Widget _wrapWithExpanded(HeaderItem? item) {
    if (item == null || item.widget == null) return const SizedBox.shrink();
    return item.isExpanded
        ? Expanded(child: _buildItem(item))
        : _buildItem(item);
  }

  Widget _buildItem(HeaderItem? item) {
    if (item == null || item.widget == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: item.width,
        height: item.height,
        margin: item.margin ?? EdgeInsets.zero,
        padding: item.padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: item.borderRadius,
          color: item.backgroundColor ?? Colors.transparent,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: item.color ?? Colors.black,
            fontSize: item.fontSize ?? 16.0,
            fontWeight: item.fontWeight ?? FontWeight.normal,
          ),
          child: Align(
            alignment: item.isCenter ? Alignment.center : Alignment.centerLeft,
            child: item.widget!,
          ),
        ),
      ),
    );
  }
}
