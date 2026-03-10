import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class Achievement {
  final String id;
  final String title;
  final int target;
  final String iconPath; // or we can use emoji for simplicity if user allows, but let's use emoji directly in UI or asset

  Achievement({
    required this.id,
    required this.title,
    required this.target,
    this.iconPath = '',
  });
}

class AchievementService {
  static const String _readCountKey = 'read_tales_count';
  static const String _tokensKey = 'user_tokens';
  static const String _claimedKey = 'claimed_achievements';

  // 10 achievements as requested
  static final List<Achievement> achievements = [
    Achievement(id: 'ach_1', title: 'İlk Adım', target: 1),
    Achievement(id: 'ach_2', title: 'Masal Meraklısı', target: 2),
    Achievement(id: 'ach_3', title: 'Kitap Kurdu', target: 3),
    Achievement(id: 'ach_4', title: 'Hikaye Avcısı', target: 4),
    Achievement(id: 'ach_5', title: 'Masal Gezgini', target: 5),
    Achievement(id: 'ach_6', title: 'Gümüş Kitap Kurdu', target: 10),
    Achievement(id: 'ach_7', title: 'Altın Masalcı', target: 20),
    Achievement(id: 'ach_8', title: 'Masal Ustası', target: 30),
    Achievement(id: 'ach_9', title: 'Bilge Baykuş', target: 50),
    Achievement(id: 'ach_10', title: 'Efsanevi Anlatıcı', target: 100),
  ];

  static final Set<String> _sessionReadTaleIds = {};

  static Future<int> getReadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_readCountKey) ?? 0;
  }

  static Future<void> incrementReadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_readCountKey) ?? 0;
    await prefs.setInt(_readCountKey, currentCount + 1);
  }

  static Future<void> markTaleAsRead(String taleId) async {
    debugPrint('AchievementService.markTaleAsRead tetiklendi. TaleID: $taleId');

    if (_sessionReadTaleIds.contains(taleId)) {
      debugPrint('AchievementService: Bu masal bu oturumda zaten okundu sayılmış: $taleId');
      return; // Bu session'da eklendiyse yapma
    }
    
    _sessionReadTaleIds.add(taleId);
    
    // Toplam sayacı artır
    await incrementReadCount();
    debugPrint('AchievementService: Toplam okuma sayısı artırıldı.');
    
    // Aktif başarım sayacını artır
    await _incrementActiveAchievementProgress();
    debugPrint('AchievementService: Aktif başarım ilerlemesi artırıldı.');
  }

  static Future<void> _incrementActiveAchievementProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final claimed = prefs.getStringList(_claimedKey) ?? [];
    
    // İlk claim edilmemiş (aktif) başarımı bul
    Achievement? activeAch;
    for (var ach in achievements) {
      if (!claimed.contains(ach.id)) {
        activeAch = ach;
        break;
      }
    }
    
    if (activeAch != null) {
      final key = 'ach_progress_${activeAch.id}';
      final currentProgress = prefs.getInt(key) ?? 0;
      
      // Eğer hedef dolmamışsa artır
      if (currentProgress < activeAch.target) {
        await prefs.setInt(key, currentProgress + 1);
      }
    }
  }

  // UI'ın göstermesi için her başarımın kendi progress'i
  static Future<int> getAchievementProgress(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('ach_progress_$achievementId') ?? 0;
  }

  static Future<int> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tokensKey) ?? 0;
  }

  static Future<void> addToken() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTokens = prefs.getInt(_tokensKey) ?? 0;
    await prefs.setInt(_tokensKey, currentTokens + 1);
  }

  static Future<List<String>> getClaimedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_claimedKey) ?? [];
  }

  static Future<void> claimAchievement(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final claimed = prefs.getStringList(_claimedKey) ?? [];
    if (!claimed.contains(id)) {
      claimed.add(id);
      await prefs.setStringList(_claimedKey, claimed);
      await addToken();
    }
  }

  /// Sadece debug / test için, sayıları sıfırlamak istersen diye
  static Future<void> resetAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_readCountKey);
    await prefs.remove(_tokensKey);
    await prefs.remove(_claimedKey);
  }
}
