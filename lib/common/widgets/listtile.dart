import 'package:flutter/material.dart';

class AppListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color tileColor;
  final BoxShape shape;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool divider;

  const AppListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.tileColor = Colors.transparent,
    this.shape = BoxShape.rectangle,
    this.onTap,
    this.onLongPress,
    this.divider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          shape: shape == BoxShape.circle
              ? const CircleBorder()
              : const RoundedRectangleBorder(),
          color: tileColor,
          child: ListTile(
            leading: Icon(leadingIcon),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: trailingIcon != null ? Icon(trailingIcon) : null,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        ),
        if (divider) const Divider(),
      ],
    );
  }
}
