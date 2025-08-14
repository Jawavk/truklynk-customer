import 'package:flutter/cupertino.dart';

@immutable
abstract class BottombarEvent {}

class BottomNavBar extends BottombarEvent {
  final int index;

  BottomNavBar({required this.index});
}
