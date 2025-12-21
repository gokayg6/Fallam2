import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../constants/app_colors.dart';
import '../../providers/theme_provider.dart';

/// Fullscreen image viewer widget
class ImageViewer extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? imageAsset;
  final String? title;

  const ImageViewer({
    super.key,
    this.imageUrl,
    this.imageBytes,
    this.imageAsset,
    this.title,
  }) : assert(
          imageUrl != null || imageBytes != null || imageAsset != null,
          'At least one image source must be provided',
        );

  static Future<void> show({
    required BuildContext context,
    String? imageUrl,
    Uint8List? imageBytes,
    String? imageAsset,
    String? title,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => ImageViewer(
        imageUrl: imageUrl,
        imageBytes: imageBytes,
        imageAsset: imageAsset,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: title != null
              ? Text(
                  title!,
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: _buildImage(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildErrorWidget(isDark),
      );
    } else if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildErrorWidget(isDark),
      );
    } else if (imageAsset != null) {
      return Image.asset(
        imageAsset!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildErrorWidget(isDark),
      );
    }
    return _buildErrorWidget(isDark);
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            'Görsel yüklenemedi',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

