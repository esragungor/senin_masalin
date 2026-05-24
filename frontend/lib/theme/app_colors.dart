import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk sabitleri.
/// Her sayfa grubunun renkleri kendi bölümünde tanımlanır.
class AppColors {
  AppColors._(); // instantiate edilemesin

  // ════════════════════════════════════════════════════
  // UYGULAMA ANA RENKLERİ
  // ════════════════════════════════════════════════════

  /// Ana buton / link / vurgu rengi
  static const Color primary = Color(0xFF308CE8);

  // ════════════════════════════════════════════════════
  // GİRİŞ YAP & KAYIT OL SAYFALARI
  // ════════════════════════════════════════════════════

  /// Giriş / Kayıt sayfaları arka plan rengi
  static const Color authBackground = Color(0xFFFCFDFF);

  /// Giriş / Kayıt AppBar arka plan rengi
  static const Color authAppBarBackground = Color(0xFFFCFDFF);

  /// Giriş / Kayıt AppBar başlık (yazı) rengi
  static const Color authAppBarTitle = Color(0xFF1A1A2E);

  // ════════════════════════════════════════════════════
  // GİRİŞ YAP & KAYIT OL — INPUT ALANLARI
  // ════════════════════════════════════════════════════

  /// Input alanı arka plan rengi
  static const Color authInputBackground = Color(0xFFFFFFFF);

  /// Input alanı kenarlık rengi (normal)
  static const Color authInputBorder = Color(0xFFE2E8F0);

  /// Input alanı kenarlık rengi (odaklanınca)
  static const Color authInputBorderFocused = Color(0xFF308CE8);

  /// Input hint yazı rengi
  static const Color authInputHint = Color(0xFFB0BAC9);

  /// Input yazı rengi
  static const Color authInputText = Color(0xFF1A1A2E);

  /// Input ikon rengi
  static const Color authInputIcon = Color(0xFFB0BAC9);

  /// Input hata kenarlık rengi
  static const Color authInputBorderError = Color(0xFFEF4444);

  // ════════════════════════════════════════════════════
  // GİRİŞ YAP & KAYIT OL — BUTONLAR
  // ════════════════════════════════════════════════════

  /// Ana buton arka plan rengi (Giriş Yap, Kayıt Ol vb.)
  static const Color authPrimaryButton = Color(0xFF308CE8);

  /// Ana buton yazı rengi
  static const Color authPrimaryButtonText = Color(0xFFFFFFFF);

  /// Google butonu arka plan rengi (beyaz/outline)
  static const Color authGoogleButton = Color(0xFFFFFFFF);

  /// Google butonu kenarlık rengi
  static const Color authGoogleButtonBorder = Color(0xFFE2E8F0);

  // ════════════════════════════════════════════════════
  // DARK MODE (GECE MODU) RENKLERİ
  // ════════════════════════════════════════════════════

  /// Derin gece mavisi (Arka Plan)
  static const Color midnightNavy = Color(0xFF0B1120);

  /// Gece mavisi cam efekti (Overlay) - *Kaldırılabilir, geriye dönük uyumluluk için var*
  static const Color glassNavy = Color(0x660B1120);

  /// Premium Glassmorphism gradyanı başlangıç (rgba(10, 15, 30, 0.85))
  static const Color premiumGlassGradientStart = Color.fromRGBO(10, 15, 30, 0.85);

  /// Premium Glassmorphism gradyanı bitiş (rgba(10, 15, 30, 0.60))
  static const Color premiumGlassGradientEnd = Color.fromRGBO(10, 15, 30, 0.60);

  /// Çok yumuşak parlama efekti (Glow)
  static const Color premiumGlassGlow = Color.fromRGBO(196, 181, 253, 0.10);
  
  /// Premium kart gölgesi
  static const Color premiumShadow = Color.fromRGBO(0, 0, 0, 0.40);

  /// Yumuşak gece mavisi gradyanı başlangıç
  static const Color softNavyGradientStart = Color(0xFF0A0F1F);
  
  /// Yumuşak gece mavisi gradyanı bitiş
  static const Color softNavyGradientEnd = Color(0xFF111827);

  /// Kirli beyaz (Birincil Başlıklar - Yumuşatılmış)
  static const Color offWhite = Color(0xFFE2E8F0);

  /// Lavanta grisi (İkincil Yazılar)
  static const Color lavenderGrey = Color(0xFF94A3B8);

  /// Yumuşak pastel mor (Vurgu - Yumuşatılmış)
  static const Color pastelPurple = Color(0xFFC4B5FD);

  /// Gün batımı turuncusu (Vurgu)
  static const Color sunsetOrange = Color(0xFFFB923C);
}

