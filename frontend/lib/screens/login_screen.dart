import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/appbar/giris_appbar.dart';
import '../widgets/inputs/giris_input.dart';
import '../widgets/dialogs/terms_dialog.dart';
import '../theme/app_colors.dart';

/// Giriş Yap ekranı — Firebase Auth ile aktif.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Giriş Yap (Email/Şifre) ──────────────────────────
  Future<void> _onGirisYap() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Email ve şifreni gir.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = AuthService.getErrorMessage(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'Bir hata oluştu. Tekrar dene.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Google ile Giriş ─────────────────────────────────
  Future<void> _onGoogleGiris() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.signInWithGoogle();
      final isNew = result['isNewUser'] as bool;

      if (!mounted) return;

      // Yeni kullanıcıysa → Sözleşme dialog
      if (isNew) {
        final accepted = await showTermsDialog(context);
        if (!accepted) {
          // Sözleşmeyi reddetti → oturumu kapat
          await AuthService.signOut();
          if (mounted) {
            setState(() => _errorMessage =
                'Devam etmek için kullanıcı sözleşmesini kabul etmelisin.');
          }
          return;
        }
      }

      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = AuthService.getErrorMessage(e.code));
    } catch (e) {
      if (e.toString().contains('iptal')) {
        setState(() => _errorMessage = null); // kullanıcı iptal etti, sessiz
      } else {
        setState(() => _errorMessage = 'Google girişi başarısız. Tekrar dene.');
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: const GirisAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Alt başlık ─────────────────────────────
              Center(
                child: Text(
                  'Sihirli masallar seni bekliyor.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 36),

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
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              // ── Şifre ──────────────────────────────────
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
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),

              // ── Şifremi Unuttum ────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Şifre sıfırlama
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Şifremi Unuttum',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // ── Hata Mesajı ────────────────────────────
              if (_errorMessage != null) ...[
                const SizedBox(height: 4),
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
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.authInputBorderError,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Giriş Yap Butonu ───────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onGirisYap,
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
                              color: AppColors.authPrimaryButtonText),
                        )
                      : const Text('Giriş Yap',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              // ── VEYA ayırıcı ───────────────────────────
              Row(children: [
                const Expanded(
                    child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('VEYA',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0)),
                ),
                const Expanded(
                    child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
              ]),

              const SizedBox(height: 16),

              // ── Google ile Devam Et ────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _isGoogleLoading ? null : _onGoogleGiris,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.authGoogleButton,
                    side: const BorderSide(
                        color: AppColors.authGoogleButtonBorder, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isGoogleLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.authInputText))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/google_logo.svg',
                                width: 22, height: 22),
                            const SizedBox(width: 10),
                            const Text('Google ile Devam Et',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.authInputText)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Kayıt Ol yönlendirmesi ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Kayıtlı değil misin?',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Hemen kaydol!',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
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
