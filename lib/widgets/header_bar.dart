import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/theme_provider.dart';
import '../screens/profile/fixed_profile_screen.dart';
import '../screens/premium/karma_purchase_screen.dart';

class HeaderBar extends StatelessWidget {
  final int karma;

  const HeaderBar({super.key, required this.karma});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.getBackground(isDark),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/fallalogo.png', height: 44, width: 44),
			  const SizedBox(width: 8),
              const Text(
                "Falla",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0C88F),
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Karma Container
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KarmaPurchaseScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE0C88F)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '✨ ',
                        style: TextStyle(
                          color: Color(0xFFE0C88F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        karma.toString(),
                        style: const TextStyle(
                          color: Color(0xFFE0C88F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Profile Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FixedProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFE0C88F).withValues(alpha: 0.1),
                    border: Border.all(color: Color(0xFFE0C88F).withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFE0C88F),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
