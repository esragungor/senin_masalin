import 'package:flutter/material.dart';

class StarBackground extends StatelessWidget {
  final Widget child;

  /// Geriye dönük uyumluluğu kırmamak için sınıf ismi aynı (StarBackground) bırakılmıştır.
  /// Kullanıcının son promptuna göre: Yalnızca `#12101A` (karanlık mod) 
  /// veya `#FCFDFF` (gündüz modu) sabit renklerini render eder.
  /// Hiçbir CustomPainter, Ticker, bulut, yıldız, gölge veya gradient içermez.
  const StarBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF12101A) : const Color(0xFFFCFDFF),
      child: child,
    );
  }
}
