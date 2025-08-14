import 'package:flutter/cupertino.dart';

@immutable
abstract class BottombarState {
  final int currentIndex;

  BottombarState({required this.currentIndex});
}

class BottomNavBarInitial extends BottombarState {
   BottomNavBarInitial({required super.currentIndex});
}