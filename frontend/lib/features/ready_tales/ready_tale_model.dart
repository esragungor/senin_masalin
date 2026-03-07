/// Hazır Masallar veri modelleri.
///
/// Bu dosyayı sadece model yapısını değiştirmek istediğinde aç.
/// Masal içeriğini değiştirmek için ilgili tales/ dosyasına git.

class ReadyTale {
  /// Masalın benzersiz kimliği (değiştirme)
  final String id;

  /// Kategorisi (Hazır Masallar listesinde gruplamak için)
  final String category;

  /// Masalın başlığı — {{PROTAGONIST}} placeholder içerebilir
  final String title;

  /// Kullanıcı isim girmezse kullanılacak varsayılan kahraman adı
  final String defaultProtagonist;

  /// Kapak fotoğrafının asset yolu — örn: 'assets/ready_tales/kirmizi_baslikli_kiz/cover.jpg'
  /// Henüz eklenmemişse null bırak, uygulama placeholder gösterir
  final String? coverAsset;

  /// Masalın sayfaları (her segment = 1 sayfa)
  final List<TaleSegment> segments;

  const ReadyTale({
    required this.id,
    required this.category,
    required this.title,
    required this.defaultProtagonist,
    required this.segments,
    this.coverAsset,
  });

  /// {{PROTAGONIST}} placeholder'larını verilen isimle değiştirir
  ReadyTale applyProtagonist(String name) {
    final effectiveName = name.trim().isEmpty ? defaultProtagonist : name.trim();
    return ReadyTale(
      id: id,
      category: category,
      title: title.replaceAll('{{PROTAGONIST}}', effectiveName),
      defaultProtagonist: defaultProtagonist,
      coverAsset: coverAsset,
      segments: segments
          .map((s) => s.applyProtagonist(effectiveName))
          .toList(),
    );
  }

  /// TaleScreen'in beklediği Map formatına çevirir
  Map<String, dynamic> toStoryData() {
    return {
      'id': id,
      'title': title,
      'isSavedTale': true,      // Çıkışta kaydetme sorusu çıkmasın
      'isReadyTale': true,      // Hazır masal olduğunu işaretle
      'segments': segments.map((s) => s.toMap()).toList(),
    };
  }
}

class TaleSegment {
  /// Sayfa metni — {{PROTAGONIST}} placeholder içerebilir
  final String text;

  /// Sayfanın görsel asset yolu — henüz eklenmemişse null bırak
  /// örn: 'assets/ready_tales/kirmizi_baslikli_kiz/page1.jpg'
  final String? imageAsset;

  const TaleSegment({
    required this.text,
    this.imageAsset,
  });

  TaleSegment applyProtagonist(String name) {
    return TaleSegment(
      text: text.replaceAll('{{PROTAGONIST}}', name),
      imageAsset: imageAsset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrl': imageAsset, // TaleScreen 'imageUrl' anahtarını bekliyor
    };
  }
}
