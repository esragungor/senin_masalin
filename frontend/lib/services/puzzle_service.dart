import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class PuzzleService {
  static const String _revealedIndicesKey = 'puzzle_revealed_indices';
  static const String _lastCollectionKey = 'puzzle_last_collection_date';
  static const String _currentPuzzleImageKey = 'current_puzzle_image';
  static const String _completedPuzzlesKey = 'puzzle_completed_list';

  // Simple single daily puzzle
  static const List<String> puzzleImages = [
    'assets/puzzles/pawpetrol.png',
  ];

  /// Returns the list of revealed piece indices.
  static Future<List<int>> getRevealedIndices() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> indicesStr = prefs.getStringList(_revealedIndicesKey) ?? [];
    return indicesStr.map(int.parse).toList();
  }

  /// Returns the number of collected pieces (0-9).
  static Future<int> getPieceCount() async {
    final indices = await getRevealedIndices();
    return indices.length;
  }

  /// Gets the current target puzzle image
  static Future<String> getCurrentPuzzleImage() async {
    return puzzleImages[0];
  }

  /// Adds a piece if today's limit hasn't been reached.
  /// Returns true if a new piece was successfully added.
  static Future<bool> addPiece({bool bypassDailyLimit = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final lastDate = prefs.getString(_lastCollectionKey);

    if (!bypassDailyLimit && lastDate == today) {
      debugPrint('PuzzleService: Zaten bugün parça toplandı.');
      return false; 
    }

    final revealedIndices = await getRevealedIndices();
    if (revealedIndices.length < 9) {
      // Mevcut olmayan bir rastgele indeks bul
      final availableIndices = List.generate(9, (i) => i).where((i) => !revealedIndices.contains(i)).toList();
      if (availableIndices.isEmpty) return false;
      
      final randomIndex = (availableIndices..shuffle()).first;
      revealedIndices.add(randomIndex);
      
      await prefs.setStringList(_revealedIndicesKey, revealedIndices.map((i) => i.toString()).toList());
      await prefs.setString(_lastCollectionKey, today);
      debugPrint('PuzzleService: Yeni parça ($randomIndex) eklendi! Toplam: ${revealedIndices.length}');
      return true;
    }
    
    return false;
  }

  /// Resets the current puzzle progress to start over.
  static Future<void> resetPuzzle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_revealedIndicesKey);
    debugPrint('PuzzleService: Puzzle sıfırlandı.');
  }

  /// For testing: Reset everything
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_revealedIndicesKey);
    await prefs.remove(_lastCollectionKey);
  }
}
