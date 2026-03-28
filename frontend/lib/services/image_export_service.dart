import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot/screenshot.dart';

class ImageExportService {
  static final ScreenshotController screenshotController = ScreenshotController();

  /// Saves a network or asset image to the gallery.
  /// If [isColoringMode] is true, it captures the filtered widget instead of the raw image.
  static Future<void> saveImage({
    required String imageUrl,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String fileName = 'tale_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');

      // Save raw image (Network or Asset)
      if (imageUrl.startsWith('http')) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Görsel indirilemedi (HTTP ${response.statusCode})');
        }
      } else {
        // It's an asset. Copy to temp file.
        final byteData = await rootBundle.load(imageUrl);
        await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      }

      // Final step: Save to gallery using Gal
      if (await file.exists()) {
        await Gal.putImage(file.path);
      } else {
        throw Exception('Dosya oluşturulamadı');
      }
    } catch (e) {
      debugPrint('ImageExportService Error: $e');
      rethrow;
    }
  }

  /// Checks and requests gallery permissions
  static Future<bool> checkPermissions() async {
    return await Gal.hasAccess();
  }

  static Future<void> requestPermissions() async {
    await Gal.requestAccess();
  }
}
