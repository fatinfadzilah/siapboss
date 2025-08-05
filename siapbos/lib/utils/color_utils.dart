import 'package:flutter/material.dart';

Color getColorForProject(String name) {
  final colors = <Color>[
    Color(0xFF1E88E5), // corporate blue
    Color(0xFF43A047), // corporate green
    Color(0xFF5E35B1), // deep purple
    Color(0xFF6D4C41), // brown
    Color(0xFF00838F), // teal
    Color(0xFF455A64), // blue grey
    Color(0xFF546E7A), // slate
    Color(0xFFEF6C00), // orange accent
  ];

  int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
  return colors[hash % colors.length];
}
