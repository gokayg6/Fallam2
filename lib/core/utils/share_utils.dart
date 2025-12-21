import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ShareUtils {
  static Future<void> captureAndShare({
    required GlobalKey key,
    String subject = 'Falla - Mistik Fal ve Astroloji',
    String text = 'Falla ile geleceğini keşfet! 🔮',
  }) async {
    try {
      // Wait for any layout/paint updates to settle
      await Future.delayed(const Duration(milliseconds: 50));

      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        debugPrint('ShareUtils: Boundary is null');
        throw Exception('Boundary is null');
      }

      // Double check if it needs paint
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // Higher pixel ratio for better quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        debugPrint('ShareUtils: ByteData is null');
        throw Exception('ByteData is null');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Get temp directory
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/falla_share_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await imagePath.writeAsBytes(pngBytes);

      // Share
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('ShareUtils Error: $e');
      rethrow; // Hata durumunda exception'ı yukarı fırlat
    }
  }
}

