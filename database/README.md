# Senin Masalın — Database Klasörü

## İçerik

| Dosya | Açıklama |
|-------|----------|
| `firestore.rules` | Firestore güvenlik kuralları |
| `firestore.indexes.json` | Composite index tanımları |
| `storage.rules` | Firebase Storage güvenlik kuralları |
| `schema/` | Koleksiyon belgesi örnekleri (dokümantasyon) |

## Firestore Koleksiyon Yapısı

```
users/{userId}                          ← Kullanıcı profili
users/{userId}/stories/{storyId}        ← Kullanıcının kaydettiği masallar
users/{userId}/avatar_unlocks/{itemId}  ← Açılmış avatarlar

premade_stories/{storyId}              ← Hazır masallar (admin)
achievements/{docId}                   ← Başarım kataloğu (admin)
avatar_items/{itemId}                  ← Avatar kataloğu (admin)
puzzle_boards/{boardId}                ← Puzzle kataloğu (admin)
jeton_transactions/{txId}             ← Jeton işlem geçmişi
tts_usage/{yearMonth}                  ← Google TTS aylık limit sayacı
```

## Firebase Console'da Yapılacaklar

1. **Firestore Rules** → Console → Firestore → Rules → `firestore.rules` içeriğini yapıştır
2. **Firestore Indexes** → Console → Firestore → Indexes → `firestore.indexes.json` içeriğini deploy et
3. **Storage Rules** → Console → Storage → Rules → `storage.rules` içeriğini yapıştır

## Deploy Komutu

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```
