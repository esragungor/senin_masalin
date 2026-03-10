import 'package:shared_preferences/shared_preferences.dart';

class LocalFavoriteService {
  static const String _key = 'favorite_ready_tales';

  /// Helper: ID'nin her zaman 'ready_' ile başlamasını garanti et
  static String _formatId(String id) {
    return id.startsWith('ready_') ? id : 'ready_$id';
  }

  /// Favori ID'lerini getir
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList.map((id) => _formatId(id)).toList();
  }

  /// Masalı favorilere ekle veya çıkar (toggle)
  static Future<bool> toggleFavorite(String taleId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_key) ?? [];
    final formattedId = _formatId(taleId);

    bool isNowFavorite;
    // Mevcut listede arama yaparken _formatId'den geçirilmiş halleri ile kontrol ediyoruz
    if (favorites.any((id) => _formatId(id) == formattedId)) {
      favorites.removeWhere((id) => _formatId(id) == formattedId);
      isNowFavorite = false;
    } else {
      favorites.add(formattedId);
      isNowFavorite = true;
    }

    await prefs.setStringList(_key, favorites);
    return isNowFavorite;
  }

  /// Belirli bir masalın favori durumunu kontrol et
  static Future<bool> isFavorite(String taleId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? [];
    final formattedId = _formatId(taleId);
    return favorites.any((id) => _formatId(id) == formattedId);
  }
}
