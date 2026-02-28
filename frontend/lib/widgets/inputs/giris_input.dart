import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Giriş Yap ve Kayıt Ol sayfaları için özel input alanı.
///
/// Kullanım örnekleri:
/// ```dart
/// GirisInput(
///   hint: 'E-posta',
///   icon: Icons.email_outlined,
///   controller: _emailController,
/// )
/// GirisInput(
///   hint: 'Şifreniz',
///   icon: Icons.lock_outline,
///   isPassword: true,
///   controller: _passwordController,
/// )
/// ```
class GirisInput extends StatefulWidget {
  const GirisInput({
    super.key,
    required this.hint,
    required this.icon,
    this.controller,
    this.isPassword = false,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool isPassword;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  State<GirisInput> createState() => _GirisInputState();
}

class _GirisInputState extends State<GirisInput> {
  bool _obscureText = true; // Şifre gizleme

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      style: const TextStyle(
        color: AppColors.authInputText,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: AppColors.authInputHint,
          fontSize: 15,
        ),
        // Sağ taraf ikonu
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.authInputIcon,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              )
            : Icon(
                widget.icon,
                color: AppColors.authInputIcon,
                size: 20,
              ),
        // Hata mesajı
        errorText: widget.errorText,
        errorStyle: const TextStyle(
          color: AppColors.authInputBorderError,
          fontSize: 12,
        ),
        // Arka plan
        filled: true,
        fillColor: AppColors.authInputBackground,
        // Kenarlıklar
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.authInputBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.authInputBorderFocused,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.authInputBorderError,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.authInputBorderError,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
