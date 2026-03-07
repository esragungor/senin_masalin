import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Auth servisi.
/// Email/Şifre ve Google ile giriş/kayıt işlemleri burada yönetilir.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Mevcut kullanıcı ─────────────────────────────────
  static User? get currentUser => _auth.currentUser;

  // ── Email ile Kayıt ───────────────────────────────────
  /// Yeni kullanıcı oluşturur ve Firestore'a bilgileri kaydeder.
  /// Kayıt başarılı → Login'e yönlendir (ana sayfaya değil).
  static Future<void> registerWithEmail({
    required String ad,
    required String soyad,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[AuthService] registerWithEmail başlatıldı: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      debugPrint('[AuthService] Kullanıcı oluşturuldu: ${user.uid}');

      // İsim güncelle
      await user.updateDisplayName('$ad $soyad');

      // Firestore'a kullanıcı belgesi oluştur
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'ad': ad.trim(),
        'soyad': soyad.trim(),
        'email': email.trim(),
        'displayName': '$ad $soyad',
        'photoURL': null,
        'createdAt': FieldValue.serverTimestamp(),
        'termsAccepted': true,
        'authProvider': 'email',
        'jetonlar': 0,
        'toplamMasal': 0,
        'seviye': 1,
      });
      debugPrint('[AuthService] Firestore kaydı tamamlandı.');
    } catch (e, st) {
      debugPrint('[AuthService] registerWithEmail HATA: $e');
      debugPrint('[AuthService] StackTrace: $st');
      rethrow;
    }
  }

  // ── Email ile Giriş ───────────────────────────────────
  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[AuthService] signInWithEmail başlatıldı: $email');
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('[AuthService] signInWithEmail başarılı.');
    } catch (e, st) {
      debugPrint('[AuthService] signInWithEmail HATA: $e');
      debugPrint('[AuthService] StackTrace: $st');
      rethrow;
    }
  }

  // ── Google ile Giriş/Kayıt ────────────────────────────
  /// Google OAuth ile giriş yapar.
  /// Döndürdüğü değer: {user, isNewUser}
  /// isNewUser = true → terms dialog göster (login ekranı için)
  static Future<Map<String, dynamic>> signInWithGoogle({
    bool termsAccepted = false,
  }) async {
    try {
    debugPrint('[AuthService] signInWithGoogle başlatıldı.');
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google girişi iptal edildi.');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

    // Yeni kullanıcıysa Firestore belgesi oluştur
    if (isNew) {
      final nameParts = (user.displayName ?? '').split(' ');
      final ad = nameParts.isNotEmpty ? nameParts.first : '';
      final soyad = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'ad': ad,
        'soyad': soyad,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'termsAccepted': termsAccepted,
        'authProvider': 'google',
        'jetonlar': 0,
        'toplamMasal': 0,
        'seviye': 1,
      });
    }

    debugPrint('[AuthService] signInWithGoogle başarılı. isNewUser=$isNew');
    return {'user': user, 'isNewUser': isNew};
    } catch (e, st) {
      debugPrint('[AuthService] signInWithGoogle HATA: $e');
      debugPrint('[AuthService] StackTrace: $st');
      rethrow;
    }
  }

  // ── Çıkış ────────────────────────────────────────────
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Kullanıcı yeni mi? ───────────────────────────────
  /// Firestore'da belge yoksa yeni kullanıcı demektir.
  static Future<bool> isNewUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return !doc.exists;
  }

  // ── Hata mesajı çevirisi ─────────────────────────────
  static String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu email ile kayıtlı hesap bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz.';
      case 'invalid-credential':
        return 'Hatalı email veya şifre.';
      case 'email-already-in-use':
        return 'Bu email zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'invalid-email':
        return 'Geçersiz email adresi.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen bekleyin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
