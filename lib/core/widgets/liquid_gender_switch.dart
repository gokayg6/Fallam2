import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium Liquid Gender Switch with fail-safe layout
/// Uses LayoutBuilder to ensure perfect fit without overflow
class LiquidGenderSwitch extends StatefulWidget {
  final String selectedGender;
  final ValueChanged<String> onChanged;

  const LiquidGenderSwitch({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  State<LiquidGenderSwitch> createState() => _LiquidGenderSwitchState();
}

class _LiquidGenderSwitchState extends State<LiquidGenderSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _moveController;
  late Animation<double> _moveAnimation;

  int _currentIndex = 0;
  int _previousIndex = 0;
  double _blobPosition = 0.0;

  final List<String> _genders = ['Male', 'Female', 'LGBT'];
  final List<IconData> _icons = [Icons.male, Icons.female, Icons.transgender];

  static const double _switchHeight = 52.0;
  // Blob will take up 80% of the item width
  static const double _blobWidthRatio = 0.8;

  // Movement velocity for glow intensity
  double _movementVelocity = 0.0;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeOutCubic,
    );
    _moveController.addListener(_updateBlobPosition);

    _currentIndex = _genders.indexOf(widget.selectedGender);
    if (_currentIndex == -1) _currentIndex = 0;
    _previousIndex = _currentIndex;
    _blobPosition = _currentIndex.toDouble();
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  void _updateBlobPosition() {
    final progress = _moveAnimation.value;
    final velocity = _moveController.velocity.abs();
    
    setState(() {
      _movementVelocity = velocity;
      _blobPosition = ui.lerpDouble(
        _previousIndex.toDouble(),
        _currentIndex.toDouble(),
        progress,
      )!;
    });
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;

    HapticFeedback.selectionClick();

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    _moveController.forward(from: 0.0);
    widget.onChanged(_genders[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemWidth = totalWidth / 3;
        final blobWidth = itemWidth * _blobWidthRatio;
        final blobHeight = _switchHeight - 8; // 4px padding top/bottom
        
        // Calculate dynamic left position
        final blobLeft = (_blobPosition * itemWidth) + (itemWidth - blobWidth) / 2;
        
        final isMoving = _moveController.isAnimating;
        final glowIntensity = isMoving ? (_movementVelocity * 0.8).clamp(0.0, 1.6) : 0.0;

        return Container(
          height: _switchHeight,
          width: totalWidth,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(_switchHeight / 2),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Stack(
            children: [
              // ClipRRect ensures everything stays inside the pill shape
              ClipRRect(
                 borderRadius: BorderRadius.circular(_switchHeight / 2),
                 child: Stack(
                   children: [
                     // Moving Blob
                     AnimatedBuilder(
                       animation: _moveAnimation,
                       builder: (context, child) {
                         return Positioned(
                           left: blobLeft,
                           top: (_switchHeight - blobHeight) / 2,
                           child: Container(
                             width: blobWidth,
                             height: blobHeight,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(blobHeight / 2),
                               gradient: LinearGradient(
                                 begin: Alignment.topLeft,
                                 end: Alignment.bottomRight,
                                 colors: [
                                   Colors.white.withOpacity(0.22 + (glowIntensity * 0.08)),
                                   Colors.white.withOpacity(0.12 + (glowIntensity * 0.05)),
                                 ],
                               ),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.white.withOpacity(0.05 + (glowIntensity * 0.1)),
                                   blurRadius: 8 + (glowIntensity * 8),
                                   spreadRadius: glowIntensity * 1.5,
                                 ),
                               ],
                             ),
                           ),
                         );
                       },
                     ),
                   ],
                 ),
              ),

              // Icons Layer (Overlay on top of blob)
              Row(
                children: List.generate(3, (index) {
                  final isSelected = index == _currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onTap(index),
                      child: Center(
                        child: AnimatedScale(
                          scale: isSelected ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            _icons[index],
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
