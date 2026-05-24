import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.pastelPurple.withAlpha(20)
              : const Color(0xFFFFB300).withAlpha(20),
          border: Border.all(
            color: isDark
                ? AppColors.pastelPurple.withAlpha(80)
                : const Color(0xFFFFB300).withAlpha(80),
            width: 1.5,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Icon(
            isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
            key: ValueKey<bool>(isDark),
            color: isDark ? AppColors.pastelPurple : const Color(0xFFFFB300),
            size: 22,
          ),
        ),
      ),
    );
  }
}
