import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/animation_service.dart';
import 'animated_card.dart';

/// Tarot kartı bileşeni
/// Mistik tarot kartı gösterimi ve animasyonları
class TarotCard extends StatefulWidget {
  final String cardName;
  final String cardDescription;
  final String cardMeaning;
  final String cardImagePath;
  final bool isReversed;
  final bool isSelected;
  final bool isRevealed;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableFlipAnimation;
  final bool enableGlow;
  final bool enableParticles;
  final bool isPremium;
  final double? width;
  final double? height;

  const TarotCard({
    super.key,
    required this.cardName,
    required this.cardDescription,
    required this.cardMeaning,
    required this.cardImagePath,
    this.isReversed = false,
    this.isSelected = false,
    this.isRevealed = false,
    this.onTap,
    this.onLongPress,
    this.enableFlipAnimation = true,
    this.enableGlow = true,
    this.enableParticles = true,
    this.isPremium = false,
    this.width,
    this.height,
  });

  @override
  State<TarotCard> createState() => _TarotCardState();
}

class _TarotCardState extends State<TarotCard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _revealController;

  late Animation<double> _flipAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _revealAnimation;

  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Flip controller
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Glow controller
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Particle controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Reveal controller
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _flipAnimation = AnimationService.createCardFlipAnimation(_flipController);
    _glowAnimation = AnimationService.createCosmicGlowAnimation(_glowController);
    _particleAnimation = AnimationService.createMagicalParticleAnimation(_particleController);
    _revealAnimation = AnimationService.createFadeInAnimation(_revealController);
  }

  void _startAnimations() {
    if (widget.enableGlow) {
      // Blinking animation disabled
      // _glowController.repeat(reverse: true);
    }
    if (widget.enableParticles) {
      // Blinking animation disabled
      // _particleController.repeat();
    }
    if (widget.isRevealed) {
      _revealController.forward();
    }
  }

  @override
  void didUpdateWidget(TarotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _revealController.forward();
      } else {
        _revealController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.enableFlipAnimation) {
      setState(() {
        _isFlipped = !_isFlipped;
      });
      if (_isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _flipAnimation,
        _glowAnimation,
        _particleAnimation,
        _revealAnimation,
      ]),
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_flipAnimation.value),
          child: _isFlipped ? _buildCardBack() : _buildCardFront(),
        );
      },
    );
  }

  Widget _buildCardFront() {
    return AnimatedCard(
      onTap: _onTap,
      onLongPress: widget.onLongPress,
      width: widget.width,
      height: widget.height,
      enableGlow: widget.enableGlow && widget.isSelected,
      enablePulse: widget.isSelected,
      enableShimmer: widget.enableParticles,
      isPremium: widget.isPremium,
      isMystical: true,
      backgroundColor: _getCardColor(),
      borderColor: _getBorderColor(),
      elevation: widget.isSelected ? 12 : 6,
      child: Stack(
        children: [
          // Card background
          _buildCardBackground(),
          
          // Card content
          _buildCardContent(),
          
          // Particles overlay
          if (widget.enableParticles)
            _buildParticlesOverlay(),
          
          // Glow overlay
          if (widget.enableGlow && widget.isSelected)
            _buildGlowOverlay(),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return AnimatedCard(
      onTap: _onTap,
      onLongPress: widget.onLongPress,
      width: widget.width,
      height: widget.height,
      enableGlow: widget.enableGlow,
      enablePulse: false,
      enableShimmer: false,
      isPremium: widget.isPremium,
      isMystical: true,
      backgroundColor: _getCardBackColor(),
      borderColor: _getBorderColor(),
      elevation: 6,
      child: Stack(
        children: [
          // Card back background
          _buildCardBackBackground(),
          
          // Card back content
          _buildCardBackContent(),
        ],
      ),
    );
  }

  Widget _buildCardBackground() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCardColor(),
            _getCardColor().withValues(alpha: 0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Opacity(
      opacity: _revealAnimation.value,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Card image
          _buildCardImage(),
          
          const SizedBox(height: 12),
          
          // Card name
          _buildCardName(),
          
          const SizedBox(height: 8),
          
          // Card description
          _buildCardDescription(),
          
          // Reversed indicator
          if (widget.isReversed)
            _buildReversedIndicator(),
        ],
      ),
    );
  }

  Widget _buildCardImage() {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(widget.cardImagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildCardName() {
    return Text(
      widget.cardName,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: _getTextColor(),
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCardDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        widget.cardDescription,
        style: TextStyle(
          fontSize: 12,
          color: _getTextColor().withValues(alpha: 0.8),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildReversedIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: const Text(
        'TERS',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCardBackBackground() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/tarot/kartlar/kartarka.png'),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
      ),
    );
  }

  Widget _buildCardBackContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mystical symbol
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getCardBackColor().withValues(alpha: 0.3),
            border: Border.all(
              color: _getBorderColor(),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 30,
            color: _getBorderColor(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Mystical text
        Text(
          AppStrings.mystical,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getBorderColor(),
            letterSpacing: 2,
          ),
        ),
        
        const SizedBox(height: 4),
        
        Text(
          'TAROT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _getBorderColor().withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildParticlesOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlePainter(
              animation: _particleAnimation.value,
              color: _getBorderColor(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlowOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8 + (_glowAnimation.value * 0.2),
                colors: [
                  _getBorderColor().withValues(alpha: _glowAnimation.value * 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCardColor() {
    if (widget.isPremium) {
      return AppColors.premium.withValues(alpha: 0.1);
    }
    if (widget.isSelected) {
      return AppColors.primary.withValues(alpha: 0.1);
    }
    return AppColors.surface;
  }

  Color _getCardBackColor() {
    if (widget.isPremium) {
      return AppColors.premium.withValues(alpha: 0.05);
    }
    return AppColors.surface.withValues(alpha: 0.8);
  }

  Color _getBorderColor() {
    if (widget.isPremium) {
      return AppColors.premium;
    }
    if (widget.isSelected) {
      return AppColors.primary;
    }
    return AppColors.secondary;
  }

  Color _getTextColor() {
    if (widget.isPremium) {
      return AppColors.premium;
    }
    return AppColors.textPrimary;
  }
}

class _ParticlePainter extends CustomPainter {
  final double animation;
  final Color color;

  _ParticlePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw floating particles
    for (int i = 0; i < 8; i++) {
      final angle = (animation * 2 * 3.14159) + (i * 3.14159 / 4);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawCircle(
        Offset(x, y),
        2 + (math.sin(animation * 3.14159 + i) * 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
