/// Kırmızı Başlıklı Kız — Masal verisi.
///
/// ✏️  METİN değiştirmek için: segments listesindeki text alanlarını güncelle.
/// 🖼️  KAPAK FOTOĞRAFI değiştirmek için: coverAsset yolunu güncelle.
/// 🖼️  SAYFA FOTOĞRAFI değiştirmek için: ilgili TaleSegment'in imageAsset yolunu güncelle.
///
/// Fotoğrafları şu klasöre koy:
///   assets/ready_tales/kirmizi_baslikli_kiz/
///     cover.jpg, page1.jpg, page2.jpg ... page9.jpg

import '../images/kirmizi_baslikli_kiz_images.dart';
import '../ready_tale_model.dart';

final kirmiziBashlikliKiz = ReadyTale(
  id: 'kirmizi_baslikli_kiz',
  category: 'Eğitici ve Ders Verici',
  title: '{{PROTAGONIST}}',
  defaultProtagonist: 'Kırmızı Başlıklı Kız',

  // 🖼️ Kapak fotoğrafı
  coverAsset: KirmiziBaslikliKizImages.cover,

  segments: [
    // ── Sayfa 1 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          'Bir varmış, bir yokmuş... Evvel zaman içinde, ormanın kenarındaki '
          'şirin bir kulübede yaşayan çok tatlı bir küçük kız varmış. '
          'Büyükannesi onu o kadar çok severmiş ki, ona kendi elleriyle '
          'kırmızı, yumuşacık bir pelerin dikmiş. Küçük kız bu pelerini '
          'o kadar çok sevmiş ki hiç üzerinden çıkarmazmış. '
          'Bu yüzden herkes ona "{{PROTAGONIST}}" dermiş.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page1.jpg',
      imageAsset: KirmiziBaslikliKizImages.page1,
    ),

    // ── Sayfa 2 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          'Güneşli ve güzel bir sabahtı. {{PROTAGONIST}}\'ın annesi, mis gibi '
          'kokan kurabiyeler ve taze meyvelerle dolu bir sepet hazırlamış. '
          'Annesi gülümseyerek, "{{PROTAGONIST}}, büyükannen biraz hastalanmış. '
          'Ona bu sepeti götürür müsün? Ama lütfen ormandaki yoldan hiç ayrılma, '
          'yabancılarla konuşma ve dikkatli ol," demiş.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page2.jpg',
      imageAsset: KirmiziBaslikliKizImages.page2,
    ),

    // ── Sayfa 3 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          '{{PROTAGONIST}}, annesini yanağından öpüp sepeti koluna takmış ve '
          'neşeyle yola koyulmuş. Orman o kadar güzelmiş ki! Rengarenk kelebekler '
          'uçuşuyor, kuşlar cıvıl cıvıl şarkılar söylüyormuş. {{PROTAGONIST}} '
          'yolda yürürken, ağaçların arkasından tüylü ve kurnaz bir Kurt çıkagelmiş. '
          'Kurt tatlı bir sesle, "Merhaba {{PROTAGONIST}}, bu güzel sabahta '
          'nereye gidiyorsun böyle?" diye sormuş.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page3.jpg',
      imageAsset: KirmiziBaslikliKizImages.page3,
    ),

    // ── Sayfa 4 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          'Küçük kız annesinin sözünü bir anlığına unutmuş ve "Büyükanneme gidiyorum, '
          'ona kurabiye ve meyve götürüyorum. Hastalanmış da," diye cevap vermiş. '
          'Kurnaz Kurt\'un aklına hemen yaramaz bir fikir gelmiş. "Bak, şuradaki '
          'çiçekler ne kadar güzel. Büyükannenle birlikte biraz çiçek toplamak '
          'istemez misin? Eminim çok mutlu olur," demiş. {{PROTAGONIST}} çiçekleri '
          'görünce çok sevinmiş ve çiçek toplamaya başlamış.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page4.jpg',
      imageAsset: KirmiziBaslikliKizImages.page4,
    ),

    // ── Sayfa 5 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          'Kurnaz Kurt ise hiç vakit kaybetmeden kestirme yoldan büyükannenin evine '
          'doğru koşmuş. Kurt, büyükannenin kapısını çalmış: Tık tık tık! '
          '"Kim o?" diye seslenmiş büyükanne. Kurt sesini incelterek, '
          '"Benim, {{PROTAGONIST}}! Sana taze kurabiyeler getirdim," demiş. '
          'Büyükanne kapıyı açınca karşısında kurdu görünce çok şaşırmış! '
          'Ama Kurt ona hiç zarar vermemiş; sadece onu nazikçe elbise dolabına '
          'saklamış ve kapısını kilitlemiş.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page5.jpg',
      imageAsset: KirmiziBaslikliKizImages.page5,
    ),

    // ── Sayfa 6 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          'Sonra Kurt büyükannenin geceliğini giymiş, gözlüğünü takmış, başlığını '
          'kafasına geçirip yatağa yatmış. Kısa bir süre sonra {{PROTAGONIST}}, '
          'elinde kocaman bir çiçek demetiyle gelmiş. Kapıyı çalmış ve içeri girmiş. '
          'Yatağa yaklaşınca büyükannesinin biraz tuhaf göründüğünü fark etmiş.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page6.jpg',
      imageAsset: KirmiziBaslikliKizImages.page6,
    ),

    // ── Sayfa 7 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          '"Büyükanne, kolların ne kadar büyük!" '
          '"Sana daha sıkı sarılabilmek için yavrum." '
          '"Büyükanne, kulakların ne kadar büyük!" '
          '"Seni daha iyi duyabilmek için yavrum." '
          '"Büyükanne, gözlerin ne kadar büyük!" '
          '"Seni daha iyi görebilmek için yavrum." '
          '{{PROTAGONIST}} biraz geriye adım atarak, '
          '"Peki büyükanne, dişlerin ne kadar büyük!" demiş.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page7.jpg',
      imageAsset: KirmiziBaslikliKizImages.page7,
    ),

    // ── Sayfa 8 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          'Kurt yataktan fırlamış! {{PROTAGONIST}} çığlık atarak evde koşuşturmaya '
          'başlamış. Tam o sırada ormandan geçmekte olan iyi kalpli, güçlü bir '
          'ormancı sesi duymuş ve hemen içeri girmiş. Ormancıyı gören korkak Kurt, '
          'kapıdan fırladığı gibi ormanın derinliklerine doğru kaçmış ve bir daha '
          'o buralara hiç uğramamış.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page8.jpg',
      imageAsset: KirmiziBaslikliKizImages.page8,
    ),

    // ── Sayfa 9 ───────────────────────────────────────────────────────────
    TaleSegment(
      text:
          'Ormancı ve {{PROTAGONIST}}, dolabı açıp büyükanneyi kurtarmışlar. '
          'Büyükanne sapasağlammış ve çok mutluymuş. Üçü birlikte masaya oturmuşlar; '
          'annesinin yaptığı nefis kurabiyeleri yeyip taze meyve sularını içmişler. '
          '{{PROTAGONIST}} o gün çok önemli bir ders almış: Bir daha asla annesinin '
          'sözünden çıkmamış ve bilmediği yollara sapmamış. '
          'Ve hepsi ömür boyu mutlu ve huzurlu yaşamışlar.',
      // 🖼️ imageAsset: 'assets/ready_tales/kirmizi_baslikli_kiz/page9.jpg',
      imageAsset: KirmiziBaslikliKizImages.page9,
    ),
  ],
);
