import 'package:flutter/material.dart';
import 'dart:math' as math;

Color cellColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? Colors.white
      : const Color.fromRGBO(80, 80, 80, 1);
}

Color backgroundColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? const Color.fromRGBO(240, 240, 250, 1)
      : const Color.fromRGBO(40, 40, 40, 1);
}

Color textColor(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light
      ? const Color.fromRGBO(15, 15, 25, 1)
      : const Color.fromRGBO(240, 240, 250, 1);
}

Color randomColor(String seed) {
  // create number representation of string seed
  double num = 1;
  for (var i = 0; i < seed.length; i++) {
    try {
      num += seed.codeUnitAt(i) / 1.9;
    } catch (error) {
      // ignore invalid characters
    }
  }
  return Color((math.Random(num.toInt()).nextDouble() * 0xFFFFFF).toInt())
      .withOpacity(1.0);
}
