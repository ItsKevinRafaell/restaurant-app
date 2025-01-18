import 'package:flutter/material.dart';

enum AppColors {
  blue("Blue", Colors.blue);

  const AppColors(this.name, this.color);

  final String name;
  final Color color;
}
