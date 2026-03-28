import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

/// Google Cloud TTS servisi.
/// Backend üzerinden Google TTS API'sini çağırır ve sesi just_audio ile çalar.
class TTSService extends ChangeNotifier {
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  final AudioPlayer _player = AudioPlayer();
  File? _tempFile;

  bool get isPlaying => _player.playing;

  /// Ses bittiğinde bildirim gönderen stream
  Stream<void> get onCompletion => _player.processingStateStream
      .where((state) => state == ProcessingState.completed)
      .distinct();

  TTSService() {
    _player.setSpeed(1.0); // Hızın her zaman normal (1x) olduğundan emin ol
    _player.playerStateStream.listen((_) {
      notifyListeners(); // Oynatma durumu değiştiğinde UI'yı haberdar et
    });
  }

  /// Verilen metni Google Cloud TTS ile seslendirir
  Future<void> speak(String text) async {
    try {
      await stop(); // Önceki sesi durdur

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/tts/synthesize'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        // MP3 verisini geçici bir dosyaya kaydet (Data URI'dan daha güvenilir)
        final tempDir = await getTemporaryDirectory();
        _tempFile = File('${tempDir.path}/tts_audio.mp3');
        await _tempFile!.writeAsBytes(response.bodyBytes);

        await _player.setFilePath(_tempFile!.path);
        await _player.setSpeed(1.0); // Oynatmadan hemen önce hızı tekrar zorla 1.0 yap
        await _player.play();
      } else {
        debugPrint('TTS Hata: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('TTSService.speak hatası: $e');
    }
  }

  /// Sesi durdurur
  Future<void> stop() async {
    try {
      await _player.stop();
      if (_tempFile != null && await _tempFile!.exists()) {
        try { await _tempFile!.delete(); } catch (_) {}
      }
    } catch (e) {
      debugPrint('TTSService.stop hatası: $e');
    }
  }

  /// Kaynakları serbest bırakır
  void dispose() {
    stop();
    _player.dispose();
  }
}
