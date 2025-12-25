import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/ai_service.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/mystical_button.dart';
import '../../core/utils/share_utils.dart';
import '../../core/widgets/liquid_glass_widgets.dart';
import '../../core/widgets/liquid_glass_navbar.dart';
import '../../providers/theme_provider.dart';

class BiorhythmScreen extends StatefulWidget {
  const BiorhythmScreen({super.key});

  @override
  State<BiorhythmScreen> createState() => _BiorhythmScreenState();
}

class _BiorhythmScreenState extends State<BiorhythmScreen> {
  DateTime? _birth;
  DateTime _date = DateTime.now();
  String? _aiText;
  bool _busy = false;
  final AIService _ai = AIService();
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user?.birthDate != null) {
        setState(() {
          _birth = user!.birthDate;
        });
      }
    });
  }

  int _daysSinceBirth() {
    if (_birth == null) return 0;
    return _date.difference(_birth!).inDays;
  }

  double _sin(double days, double period) => math.sin(2 * math.pi * days / period);

  Map<String, double> _compute() {
    final d = _daysSinceBirth().toDouble();
    final physical = _sin(d, 23);
    final emotional = _sin(d, 28);
    final mental = _sin(d, 33);
    final score = ((physical + emotional + mental) / 3.0 + 1) * 50; // 0-100 ölçek
    return {
      'physical': physical,
      'emotional': emotional,
      'mental': mental,
      'score': score.clamp(0, 100),
    };
  }

  Future<void> _aiComment() async {
    if (_birth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.selectBirthDateFirst)),
      );
      return;
    }
    setState(() {
      _busy = true;
      _aiText = null;
    });
    MysticLoading.show(context);
    try {
      final res = _compute();
      final p = res['physical']!.toStringAsFixed(2);
      final e = res['emotional']!.toStringAsFixed(2);
      final m = res['mental']!.toStringAsFixed(2);
      final s = res['score']!.toStringAsFixed(0);
      final msg = 'Biyoritim yorumu isteği. Tarih: ${DateFormat('yyyy-MM-dd').format(_date)}. '
          'Değerler (-1 ile +1 arası): Fiziksel:$p, Duygusal:$e, Zihinsel:$m. '
          'Ortalama Enerji Puanı: %$s. '
          'Bu değerlere göre kişinin güncel durumunu analiz et. Hangi döngü yüksek, hangisi düşük? '
          'Buna göre günün enerjisini 2-3 cümleyle yorumla ve tavsiye ver. Mistik ve motive edici bir dil kullan. Emoji ekle.';
      final text = await _ai.generateMysticReply(
        userMessage: msg,
        topic: MysticTopic.biorhythm,
        extras: {
          'type': 'biorhythm',
          'birthDate': _birth!.toIso8601String(),
          'date': _date.toIso8601String(),
        },
      );
      if (!mounted) return;
      setState(() => _aiText = text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.aiCommentCouldNotBeRetrieved} $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
      await MysticLoading.hide(context);
    }
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) setState(() => _birth = picked);
  }

  @override
  Widget build(BuildContext context) {
    final res = _compute();
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: themeProvider.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateSelector(),
                      const SizedBox(height: 24),
                      _buildScoreCircle(res['score']!.toDouble()),
                      const SizedBox(height: 24),
                      _buildChart(),
                      const SizedBox(height: 24),
                      _buildDetailBars(res),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.center,
                        child: MysticalButton.primary(
                          text: _busy ? AppStrings.gettingComment : AppStrings.getAIComment,
                          onPressed: _busy ? null : _aiComment,
                          width: double.infinity,
                          icon: Icons.psychology,
                          showGlow: true,
                        ),
                      ),
                      if (_aiText != null) ...[
                        const SizedBox(height: 24),
                        _buildResultCard(res['score']!),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LiquidGlassCard(
        borderRadius: 20,
        blurAmount: 15,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.biorhythmTitle,
                style: AppTextStyles.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            LiquidGlassCard(
              padding: const EdgeInsets.all(8),
              borderRadius: 12,
              blurAmount: 10,
              glowColor: const Color(0xFF9C27B0).withOpacity(0.5),
              child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
            ),
             const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassButton(
            label: AppStrings.birthDateLabel.replaceAll(':', ''),
            value: _birth == null ? AppStrings.select : DateFormat('dd.MM.yyyy').format(_birth!),
            onTap: _pickBirth,
            icon: Icons.cake,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassButton(
            label: AppStrings.date,
            value: DateFormat('dd.MM.yyyy').format(_date),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(1950),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _date = picked);
            },
            icon: Icons.calendar_today,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        blurAmount: 15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(double score) {
    return Center(
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2A72), Color(0xFF009FFD)], // Cosmic Blue Gradient
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF009FFD).withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.dailyBalance,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '%${score.toInt()}',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.blueAccent.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final days = List.generate(13, (i) => i - 6);
    final base = _daysSinceBirth().toDouble();
    final phys = days.map((d) => _sin(base + d, 23)).toList();
    final emo = days.map((d) => _sin(base + d, 28)).toList();
    final ment = days.map((d) => _sin(base + d, 33)).toList();

    return SizedBox(
      height: 200,
      child: LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      blurAmount: 20,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.minus6Days, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
              Text(AppStrings.today, style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
              Text(AppStrings.plus6Days, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _BiorhythmPainter(phys, emo, ment),
              child: Container(),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDetailBars(Map<String, double> res) {
    return Column(
      children: [
        _buildBar(AppStrings.physical, res['physical']!, const Color(0xFFFF5252)),
        const SizedBox(height: 12),
        _buildBar(AppStrings.emotional, res['emotional']!, const Color(0xFF448AFF)),
        const SizedBox(height: 12),
        _buildBar(AppStrings.mental, res['mental']!, const Color(0xFFFFAB40)),
      ],
    );
  }

  Widget _buildBar(String title, double value, Color color) {
    final pct = ((value + 1) / 2 * 100).clamp(0, 100);
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 12,
      blurAmount: 10,
      glowColor: color.withOpacity(0.2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '%${pct.toInt()}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100.0,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(double score) {
    return RepaintBoundary(
      key: _cardKey,
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        blurAmount: 25,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.fallaComment,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () => ShareUtils.captureAndShare(
                    key: _cardKey,
                    text: 'Günlük Biyoritim Dengem: %${score.toStringAsFixed(0)}\n\n$_aiText\n\nFalla ile enerjini keşfet!',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _aiText!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.95),
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BiorhythmPainter extends CustomPainter {
  final List<double> phys;
  final List<double> emo;
  final List<double> ment;
  _BiorhythmPainter(this.phys, this.emo, this.ment);

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Midline (0 line)
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), axis);
    
    // Grid lines (optional)
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), axis);

    void drawLine(List<double> vals, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.5), color],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final path = Path();
      for (int i = 0; i < vals.length; i++) {
        final x = i / (vals.length - 1) * size.width;
        final y = size.height * (1 - (vals[i] + 1) / 2); // -1..1 -> 1..0
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          // Smooth curve
          final prevX = (i - 1) / (vals.length - 1) * size.width;
          final prevY = size.height * (1 - (vals[i - 1] + 1) / 2);
          final controlX = (prevX + x) / 2;
          path.cubicTo(controlX, prevY, controlX, y, x, y);
        }
      }
      
      // Shadow for glow effect
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, paint);
    }

    drawLine(phys, const Color(0xFFFF5252));
    drawLine(emo, const Color(0xFF448AFF));
    drawLine(ment, const Color(0xFFFFAB40));
  }

  @override
  bool shouldRepaint(covariant _BiorhythmPainter oldDelegate) =>
      oldDelegate.phys != phys || oldDelegate.emo != emo || oldDelegate.ment != ment;
}


