import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ShaderPainter extends CustomPainter {
  ShaderPainter(
    this.shader, {
    this.borderRadius = 0,
  });
  final ui.FragmentShader shader;
  final double borderRadius;
  @override
  void paint(Canvas canvas, Size size) {
    try {
      if (size.width <= 0 || size.height <= 0) {
        return;
      }
      final paint = Paint()..shader = shader;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(borderRadius),
        ),
        paint,
      );
    } catch (e) {
      final paint = Paint()..color = Colors.transparent;
      canvas.drawRect(Offset.zero & size, paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
