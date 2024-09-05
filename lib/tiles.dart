import 'package:flutter/material.dart';

class Tiles {
  final int x;
  final int y;
  int val;

  late Animation<double> animationX;
  late Animation<double> animationY;
  late Animation<double> scale;
  late Animation<int> animatedvalue;

  Tiles(this.x, this.y, this.val) {
    resetAnimations();
  }

  void resetAnimations() {
    animationX = AlwaysStoppedAnimation(this.x.toDouble());
    animationY = AlwaysStoppedAnimation(this.y.toDouble());
    animatedvalue = AlwaysStoppedAnimation(this.val);
    scale = AlwaysStoppedAnimation(1.0);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    animationX = Tween(begin: this.x.toDouble(), end: x.toDouble())
        .animate(CurvedAnimation(parent: parent, curve: const Interval(0, 0.4, curve: Curves.easeOut)));
    animationY = Tween(begin: this.y.toDouble(), end: y.toDouble())
        .animate(CurvedAnimation(parent: parent, curve: const Interval(0, 0.4, curve: Curves.easeOut)));
  }

  void bounce(Animation<double> parent) {
    scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(CurvedAnimation(parent: parent, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
  }

  void appear(Animation<double> parent) {
    scale = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: parent, curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack)));
  }

  void changenumber(Animation<double> parent, int newVal) {
    animatedvalue = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(val), weight: 0.01),
      TweenSequenceItem(tween: ConstantTween(newVal), weight: 0.99),
    ]).animate(CurvedAnimation(parent: parent, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
  }
}
