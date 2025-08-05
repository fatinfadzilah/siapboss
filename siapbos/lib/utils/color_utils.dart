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

Color getColorForMemo(String location) {
  final corporateColors = <Color>[
    Color(0xFFE0E0E0), // light grey
    Color(0xFFB3E5FC), // muted blue
    Color(0xFFDCEDC8), // soft green
    Color(0xFFFFF9C4), // light yellow
    Color(0xFFFFE0B2), // warm peach
    Color(0xFFD1C4E9), // muted lavender
    Color(0xFFCFD8DC), // blue-grey
    Color(0xFFFFCDD2), // soft red
  ];


  int hash = location.codeUnits.fold(0, (prev, elem) => prev + elem);
  return corporateColors[hash % corporateColors.length];
}