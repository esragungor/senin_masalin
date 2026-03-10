import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class TaleService {
  // Fiziksel cihaz için: flutter run (varsayılan IP kullanılır)
  // Emütatör için: flutter run --dart-define=BASE_URL=http://10.0.2.2:5000/api
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.179:5000/api',
  );

  static Future<Map<String, dynamic>> generateTale({
    required String childName,
    required int childAge,
    required String theme,
    required String gender,
    required String companion,
    required String specialObject,
    required String moral,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Masal oluşturmak için giriş yapmalısınız.');
    }

    final token = await user.getIdToken();
    
    debugPrint('TaleService: Hikaye isteği atılıyor...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stories/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'childName': childName,
          'age': childAge,
          'gender': gender,
          'theme': theme,
          'companion': companion,
          'specialObject': specialObject,
          'moral': moral,
        }),
      ).timeout(
        const Duration(minutes: 3),
        onTimeout: () => throw Exception('İstek zaman aşımına uğradı. Lütfen tekrar deneyin.'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('TaleService: Masal başarıyla üretildi!');
        return data;
      } else {
        debugPrint('TaleService: Masal üretilirken hata! Status: ${response.statusCode} Body: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Bilinmeyen bir hata oluştu');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('TaleService: Ağ bağlantı hatası: $e');
      throw Exception('Sunucuya bağlanılamadı. IP adresini ve bağlantını kontrol et.');
    }
  }

  /// Oluşturulan masalı veritabanına kaydeder
  static Future<Map<String, dynamic>> saveTale(Map<String, dynamic> storyData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Masal kaydetmek için giriş yapmalısınız.');
    }

    final token = await user.getIdToken();
    debugPrint('TaleService: Masal kaydediliyor...');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stories/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(storyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('TaleService: Masal başarıyla kaydedildi!');
        return data;
      } else {
        debugPrint('TaleService: Masal kaydedilirken hata! Status: ${response.statusCode} Body: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Bilinmeyen bir hata oluştu');
      }
    } catch (e) {
      debugPrint('TaleService: Kaydetme sırasında ağ hatası: $e');
      throw Exception('Bağlantı hatası oluştu: $e');
    }
  }

  /// Kullanıcının daha önce kaydettiği tüm masalları getirir
  static Future<List<Map<String, dynamic>>> getMyTales() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Masallarınızı görmek için giriş yapmalısınız.');
    }

    final token = await user.getIdToken();
    debugPrint('TaleService: Masallar getiriliyor...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stories/my-stories'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception('Bağlantı zaman aşımına uğradı.'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('TaleService: Masallar başarıyla çekildi!');
        List<dynamic> storiesDynamic = data['stories'] ?? [];
        return storiesDynamic.map((s) => s as Map<String, dynamic>).toList();
      } else {
        debugPrint('TaleService: Masallar çekilirken hata! Status: ${response.statusCode} Body: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Bilinmeyen bir hata oluştu');
      }
    } catch (e) {
      debugPrint('TaleService: Masalları çekerken ağ hatası: $e');
      throw Exception('Bağlantı hatası oluştu: $e');
    }
  }

  /// Masalı veritabanından tamamen siler
  static Future<void> deleteTale(String taleId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Masal silmek için giriş yapmalısınız.');
    }

    final token = await user.getIdToken();
    debugPrint('TaleService: Masal siliniyor... ID: $taleId');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/stories/$taleId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('TaleService: Masal başarıyla silindi!');
      } else {
        debugPrint('TaleService: Masal silinirken hata! Status: ${response.statusCode} Body: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Bilinmeyen bir hata oluştu');
      }
    } catch (e) {
      debugPrint('TaleService: Silme sırasında ağ hatası: $e');
      throw Exception('Bağlantı hatası oluştu: $e');
    }
  }
  /// Masalı favorilere ekler veya çıkarır
  static Future<void> toggleFavorite(String storyId, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Giriş yapmalısınız.');

    final token = await user.getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/stories/favorite'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'storyId': storyId, 'isFavorite': isFavorite}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Favori güncellenemedi');
    }
  }
}
