import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

/// Falla logosunu cache'leyen widget
/// Logo bir kez yüklenir ve memory'de tutulur
class CachedFallaLogo extends StatefulWidget {
  final double? width;
  final double? height;
  final double? size;
  final Color? color;
  final BoxFit fit;

  const CachedFallaLogo({
    Key? key,
    this.width,
    this.height,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<CachedFallaLogo> createState() => _CachedFallaLogoState();
}

class _CachedFallaLogoState extends State<CachedFallaLogo> {
  static ui.Image? _cachedImage;
  static bool _isLoading = false;
  static final List<VoidCallback> _pendingCallbacks = [];

  @override
  void initState() {
    super.initState();
    _loadImageIfNeeded();
  }

  Future<void> _loadImageIfNeeded() async {
    if (_cachedImage != null) {
      if (mounted) setState(() {});
      return;
    }
    
    if (_isLoading) {
      // Zaten yükleniyor, callback ekle
      _pendingCallbacks.add(() {
        if (mounted) setState(() {});
      });
      return;
    }
    
    _isLoading = true;
    try {
      final ByteData data = await rootBundle.load('assets/icons/fallalogo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      _cachedImage = frameInfo.image;
      
      // Tüm bekleyen callback'leri çağır
      for (final callback in _pendingCallbacks) {
        callback();
      }
      _pendingCallbacks.clear();
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading Falla logo: $e');
      _pendingCallbacks.clear();
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedImage == null) {
      // Logo yüklenene kadar placeholder göster
      return SizedBox(
        width: widget.size ?? widget.width ?? 24,
        height: widget.size ?? widget.height ?? 24,
        child: Icon(
          Icons.auto_awesome,
          color: widget.color ?? Colors.white,
          size: widget.size ?? 24,
        ),
      );
    }

    final double width = widget.size ?? widget.width ?? 24;
    final double height = widget.size ?? widget.height ?? 24;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _FallaLogoPainter(
          image: _cachedImage!,
          color: widget.color,
          fit: widget.fit,
        ),
      ),
    );
  }
}

class _FallaLogoPainter extends CustomPainter {
  final ui.Image image;
  final Color? color;
  final BoxFit fit;

  _FallaLogoPainter({
    required this.image,
    this.color,
    required this.fit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint();
    
    if (color != null) {
      // Color filter uygula
      paint.colorFilter = ColorFilter.mode(color!, BlendMode.srcATop);
    }

    // Image'ı çiz
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      paint,
    );
  }

  @override
  bool shouldRepaint(_FallaLogoPainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.color != color;
  }
}

