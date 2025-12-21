import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'base_shader.dart'; // Local import
import 'shader_painter.dart'; // Local import

class BackgroundCaptureWidget extends StatefulWidget {
  const BackgroundCaptureWidget({
    super.key,
    required this.child,
    required this.width, // Configured: 160
    required this.height, // Configured: 160
    required this.shader,
    this.initialPosition,
    this.captureInterval = const Duration(microseconds: 8333), // Configured: ~120fps
    this.backgroundKey,
  });
  final Widget child;
  final double width;
  final double height;
  final Offset? initialPosition;
  final Duration? captureInterval;
  final GlobalKey? backgroundKey;
  final BaseShader shader;
  @override
  State<BackgroundCaptureWidget> createState() =>
      _BackgroundCaptureWidgetState();
}
class _BackgroundCaptureWidgetState extends State<BackgroundCaptureWidget>
    with TickerProviderStateMixin {
  late Offset position;
  Timer? timer;
  bool isCapturing = false;
  ui.Image? capturedBackground;
  @override
  void initState() {
    super.initState();
    position = widget.initialPosition ?? const Offset(100, 100);
    _startContinuousCapture();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureBackground();
    });
  }
  @override
  void dispose() {
    timer?.cancel();
    capturedBackground?.dispose();
    super.dispose();
  }
  void _startContinuousCapture() {
    if (widget.captureInterval != null) {
      timer = Timer.periodic(widget.captureInterval!, (timer) {
        if (mounted && !isCapturing) {
          _captureBackground();
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // Child wrapped in clip for the glass effect shape
    final Widget content = SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50), // Configured: 50
        child: _buildWidgetContent(),
      ),
    );
    // Modified: Remove absolute positioning/Draggable for Navbar integration
    // We just want to capture background relative to where this widget is placed
    // But original code uses Positioned/Draggable.
    // For navbar integration, we likely want just the content part, but we need the background capture logic.
    // The capture logic relies on findRenderObject() which works regardless of Positioned.
    // However, the original code wraps it in Positioned assuming it's in a Stack.
    // Since we are putting this INSIDE the navbar which is already positioned, 
    // we should modify this to be just the widget, OR wrap it in a Stack locally if needed.
    // BUT the user asked for "EXACT code provided".
    // I will use it as is, but when I integrate it into navbar, I might need to adapt if it crashes because it's not in a Stack.
    // Actually, Draggable expects to be in a context where it can drag? No, Draggable is a widget.
    // Positioned MUST be in a Stack.
    // If I put this in Navbar, Navbar uses Stack?
    // Let's look at LiquidGlassNavbar later. 
    // For now, I'll write the file as requested, but I'll make it adaptable. 
    // Actually, force Positioned might break it if not in Stack. 
    // I'll assume the user wants the LOGIC and Widget, but maybe not the exact Positioned wrapper if it breaks.
    // User said: "create the following files with the exact code provided below".
    // I will write it EXACTLY as provided.
    
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: const SizedBox.square(),
        childWhenDragging: content,
        onDragUpdate: (details) {
          setState(() {
            position = position + details.delta;
          });
          if (!isCapturing) {
            _captureBackground();
          }
        },
        onDragEnd: (details) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _captureBackground();
          });
        },
        child: content,
      ),
    );
  }
  Widget _buildWidgetContent() {
    if (widget.shader.isLoaded && capturedBackground != null) {
      widget.shader.updateShaderUniforms(
        width: widget.width,
        height: widget.height,
        backgroundImage: capturedBackground,
      );
      return CustomPaint(
        size: Size(widget.width, widget.height),
        painter: ShaderPainter(
          widget.shader.shader,
          borderRadius: 50, // Match border radius
        ),
        child: widget.child,
      );
    }
    return widget.child;
  }
  Future<void> _captureBackground() async {
    if (isCapturing || !mounted) return;
    isCapturing = true;
    try {
      final boundary = widget.backgroundKey?.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      final ourBox = context.findRenderObject() as RenderBox?;
      if (boundary == null || !boundary.attached || ourBox == null || !ourBox.hasSize) return;
      final boundaryBox = boundary as RenderBox;
      if (!boundaryBox.hasSize || widget.width <= 0 || widget.height <= 0) return;
      
      // Calculate position relative to the boundary
      final widgetRectInBoundary = Rect.fromPoints(
        boundaryBox.globalToLocal(ourBox.localToGlobal(Offset.zero)),
        boundaryBox.globalToLocal(ourBox.localToGlobal(ourBox.size.bottomRight(Offset.zero))),
      );
      final boundaryRect = Rect.fromLTWH(0, 0, boundaryBox.size.width, boundaryBox.size.height);
      final Rect regionToCapture = widgetRectInBoundary.intersect(boundaryRect);
      if (regionToCapture.isEmpty) return;
      final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final OffsetLayer offsetLayer = boundary.debugLayer! as OffsetLayer;
      final ui.Image croppedImage = await offsetLayer.toImage(
        regionToCapture,
        pixelRatio: pixelRatio,
      );
      if (mounted) {
        setState(() {
          capturedBackground?.dispose();
          capturedBackground = croppedImage;
        });
      } else {
        croppedImage.dispose();
      }
    } catch (e) {
      debugPrint('Error capturing background: $e');
    } finally {
      if (mounted) {
        isCapturing = false;
      }
    }
  }
}
