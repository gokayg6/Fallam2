import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/glassmorphism_components.dart';
import '../../core/constants/app_text_styles.dart';

// Generic Picker
Future<String?> showLiquidGlassPicker({
  required BuildContext context,
  required List<String> items,
  String? initialValue,
  required String title,
}) {
  int initialIndex = 0;
  if (initialValue != null) {
    initialIndex = items.indexOf(initialValue);
    if (initialIndex == -1) initialIndex = 0;
  }
  
  // Use a ValueNotifier to track current selection within the sheet without full rebuilds if needed,
  // but simpler to just use FixedExtentScrollController
  final scrollController = FixedExtentScrollController(initialItem: initialIndex);
  int selectedIndex = initialIndex;

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    isScrollControlled: true,
    builder: (context) {
      return _GlassPickerContainer(
        title: title,
        onDone: () {
          Navigator.pop(context, items[selectedIndex]);
        },
        child: CupertinoPicker(
          scrollController: scrollController,
          itemExtent: 40,
          backgroundColor: Colors.transparent,
          onSelectedItemChanged: (index) {
            selectedIndex = index;
          },
          selectionOverlay: Container(
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: AppColors.champagneGold.withValues(alpha: 0.5), 
                  width: 0.5
                ),
              ),
              color: AppColors.champagneGold.withValues(alpha: 0.1),
            ),
          ),
          children: items.map((item) {
            return Center(
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  item,
                  style: PremiumTextStyles.body.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}

// Date Picker
Future<DateTime?> showLiquidGlassDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  DateTime tempDate = initialDate ?? DateTime.now();

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    isScrollControlled: true,
    builder: (context) {
      return _GlassPickerContainer(
        title: 'Tarih Seçiniz',
        onDone: () {
          Navigator.pop(context, tempDate);
        },
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Brightness.dark,
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: PremiumTextStyles.body.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: tempDate,
            minimumDate: firstDate,
            maximumDate: lastDate,
            backgroundColor: Colors.transparent,
            onDateTimeChanged: (date) {
              tempDate = date;
            },
          ),
        ),
      );
    },
  );
}


class _GlassPickerContainer extends StatelessWidget {
  final Widget child;
  final String title;
  final VoidCallback onDone;

  const _GlassPickerContainer({
    Key? key,
    required this.child,
    required this.title,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2C2C3E).withValues(alpha: 0.9),
              const Color(0xFF1A1A2E).withValues(alpha: 0.95),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: PremiumTextStyles.headline.copyWith(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: onDone,
                    child: Text(
                      'Tamam',
                      style: TextStyle(
                        color: AppColors.champagneGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
            
            // Picker Content
            Expanded(
              child: child,
            ),
            
            // Safe area spacer
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}
