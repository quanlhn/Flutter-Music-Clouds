import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MyInheritedWidget extends InheritedWidget {
  bool isAppPlaying;
  final AudioPlayer player;
  @override
  final Widget child;

  MyInheritedWidget({super.key, 
    required this.isAppPlaying,
    required this.player,
    required this.child,
  }) : super(child: child);

  void updateIsAppPlaying(bool newValue) {
    if (isAppPlaying != newValue) {
      isAppPlaying = newValue;
    }
  }

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return isAppPlaying != oldWidget.isAppPlaying;
  }

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }
}
