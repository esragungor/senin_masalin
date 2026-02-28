import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/appbar/kayit_appbar.dart';
import '../widgets/inputs/giris_input.dart';
import '../theme/app_colors.dart';

/// Kayıt Ol ekranı — gerçek zamanlı şifre gücü göstergesi ile.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController =
      TextEditingController();

  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String _passwordValue = '';
  String? _generalError;

  // ── Hata mesajları ────────────────────────────────────
  String? _passwordRepeatError;
  bool _termsError = false;

  // ── Şifre kuralları ───────────────────────────────────
  bool get _hasUppercase => _passwordValue.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passwordValue.contains(RegExp(r'[a-z]'));
  bool get _hasPunctuation =>
      _passwordValue.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,.<>?/\\|`~]'));
  bool get _hasMinLength => _passwordValue.length >= 8;
  bool get _isPasswordValid =>
      _hasUppercase && _hasLowercase && _hasPunctuation && _hasMinLength;

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  // ── Form doğrulama ────────────────────────────────────
  bool _validate({bool forGoogle = false}) {
    String? pwRepeatError;
    bool termsErr = false;

    if (!forGoogle) {
      if (_passwordValue != _passwordRepeatController.text) {
        pwRepeatError = 'Şifreler uyuşmuyor.';
      }
    }

    if (!_termsAccepted) termsErr = true;

    setState(() {
      _passwordRepeatError = pwRepeatError;
      _termsError = termsErr;
    });

    // Şifre geçerliliği de kontrol et
    return _isPasswordValid && pwRepeatError == null && !termsErr;
  }

  // ── Kayıt Ol (Email/Şifre) ──────────────────────────
  Future<void> _onKayitOl() async {
    if (!_validate()) return;
    setState(() { _isLoading = true; _generalError = null; });
    try {
      await AuthService.registerWithEmail(
        ad: _nameController.text.trim(),
        soyad: _lastnameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Şimdi giriş yapabilirsin.'),
            backgroundColor: Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/login');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _generalError = AuthService.getErrorMessage(e.code));
    } catch (_) {
      setState(() => _generalError = 'Bir hata oluştu. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Google ile Kayıt ─────────────────────────────────
  Future<void> _onGoogleKayit() async {
    if (!_validate(forGoogle: true)) return;
    setState(() { _isGoogleLoading = true; _generalError = null; });
    try {
      await AuthService.signInWithGoogle(termsAccepted: true);
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _generalError = AuthService.getErrorMessage(e.code));
    } catch (e) {
      if (!e.toString().contains('iptal')) {
        setState(() => _generalError = 'Google ile kayıt başarısız. Tekrar dene.');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: const KayitAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Adın ───────────────────────────────────
              const Text('Adın',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authInputText)),
              const SizedBox(height: 8),
              GirisInput(
                hint: 'Adınız',
                icon: Icons.person_outline,
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 20),

              // ── Soyadın ────────────────────────────────
              const Text('Soyadın',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authInputText)),
              const SizedBox(height: 8),
              GirisInput(
                hint: 'Soyadınız',
                icon: Icons.person_outline,
                controller: _lastnameController,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 20),

              // ── E-posta ────────────────────────────────
              const Text('E-posta',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authInputText)),
              const SizedBox(height: 8),
              GirisInput(
                hint: 'ornek@gmail.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // ── Şifre ────────────────────────────────
              const Text('Şifre',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authInputText)),
              const SizedBox(height: 8),
              GirisInput(
                hint: '********',
                icon: Icons.lock_outline,
                controller: _passwordController,
                isPassword: true,
                onChanged: (val) => setState(() => _passwordValue = val),
              ),

              // ── Şifre Gücü Göstergeleri ────────────────
              if (_passwordValue.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PasswordRule(
                  label: 'En az 8 karakter',
                  isMet: _hasMinLength,
                ),
                const SizedBox(height: 6),
                _PasswordRule(
                  label: 'En az 1 büyük harf (A-Z)',
                  isMet: _hasUppercase,
                ),
                const SizedBox(height: 6),
                _PasswordRule(
                  label: 'En az 1 küçük harf (a-z)',
                  isMet: _hasLowercase,
                ),
                const SizedBox(height: 6),
                _PasswordRule(
                  label: 'En az 1 noktalama işareti (!@#\$...)',
                  isMet: _hasPunctuation,
                ),
              ],

              const SizedBox(height: 20),

              // ── Şifre Tekrar ───────────────────────────
              const Text('Şifre Tekrar',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authInputText)),
              const SizedBox(height: 8),
              GirisInput(
                hint: '********',
                icon: Icons.lock_outline,
                controller: _passwordRepeatController,
                isPassword: true,
                errorText: _passwordRepeatError,
                onChanged: (_) {
                  if (_passwordRepeatError != null) {
                    setState(() => _passwordRepeatError = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              // ── Kullanım Şartları Checkbox ─────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _termsAccepted,
                      onChanged: (val) => setState(() {
                        _termsAccepted = val ?? false;
                        if (_termsAccepted) _termsError = false;
                      }),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      side: BorderSide(
                        color: _termsError
                            ? AppColors.authInputBorderError
                            : AppColors.authInputBorder,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _termsAccepted = !_termsAccepted;
                        if (_termsAccepted) _termsError = false;
                      }),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: _termsError
                                ? AppColors.authInputBorderError
                                : Colors.grey[600],
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Kullanıcı Sözleşmesini ve Gizlilik Politikasını',
                              style: TextStyle(
                                color: _termsError
                                    ? AppColors.authInputBorderError
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' okudum ve kabul ediyorum.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Genel Hata Mesajı ──────────────────────
              if (_generalError != null) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.authInputBorderError.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.authInputBorderError.withAlpha(80)),
                  ),
                  child: Text(
                    _generalError!,
                    style: const TextStyle(
                      color: AppColors.authInputBorderError,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Kayıt Ol Butonu ────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onKayitOl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.authPrimaryButton,
                    foregroundColor: AppColors.authPrimaryButtonText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.authPrimaryButtonText,
                          ),
                        )
                      : const Text(
                          'Kayıt Ol 🪄',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Google ile Kayıt Ol ────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _onGoogleKayit,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.authGoogleButton,
                    side: const BorderSide(
                      color: AppColors.authGoogleButtonBorder,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/google_logo.svg',
                          width: 22, height: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Google ile Kayıt Ol',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authInputText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Giriş Yap yönlendirmesi ────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Zaten hesabın var mı?',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[500])),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek bir şifre kuralını gösteren satır widget'ı.
/// Kural sağlandığında kırmızıdan yeşile döner.
class _PasswordRule extends StatelessWidget {
  const _PasswordRule({required this.label, required this.isMet});

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final color = isMet ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isMet ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
