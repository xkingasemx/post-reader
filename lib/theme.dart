import 'package:flutter/material.dart';

const forest = Color(0xFF173F36);
const paper = Color(0xFFF5F5EE);
const ink = Color(0xFF1D3029);
const muted = Color(0xFF52635C);
const gold = Color(0xFF9C5E08);
const line = Color(0xFFDCE2D8);

ThemeData readerTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: forest,
  ).copyWith(primary: forest, surface: Colors.white, onSurface: ink);
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'ReaderRoboto',
    scaffoldBackgroundColor: paper,
    colorScheme: colors,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      toolbarHeight: 72,
      backgroundColor: forest,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      titleTextStyle: TextStyle(
        fontFamily: 'ReaderRoboto',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.8,
      ),
    ),
  );
}
