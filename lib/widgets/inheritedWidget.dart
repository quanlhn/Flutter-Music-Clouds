import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MyInheritedWidget extends InheritedWidget {
  final int count;
  final AudioPlayer player;
  final Widget child;

  MyInheritedWidget({
    required this.count,
    required this.player,
    required this.child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return false;
  }

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }
}
