import '../ready_tale_model.dart';
import '../images/hansel_gretel_images.dart';

final hanselGretel = ReadyTale(
  id: 'hansel_gretel',
  title: 'Hansel ve Gretel',
  category: 'Zeka ve Kurnazlık',
  defaultProtagonist: 'Hansel',
  coverAsset: HanselGretelImages.cover,
  segments: [
    TaleSegment(
      text: 'Bir varmış, bir yokmuş... Yemyeşil ağaçların arasından güneşin süzüldüğü, kuşların neşeyle cıvıldadığı büyük bir ormanın kenarında yaşayan {{PROTAGONIST}} ve Gretel adında iki kardeş varmış. {{PROTAGONIST}} çok zeki, Gretel ise çok dikkatli bir çocukmuş.',
      imageAsset: HanselGretelImages.page1,
    ),
    TaleSegment(
      text: 'Bir gün iki kardeş, ormanda en güzel çilekleri toplamak için biraz derinlere dalmışlar. Çilek toplarken o kadar eğlenmişler ki, güneş yavaşça batmaya başladığında yollarını birazcık şaşırmışlar. Gretel, "Endişelenme {{PROTAGONIST}}," demiş. "Yolda gelirken geçtiğimiz taşları ve renkli çiçekleri hatırlıyorum."',
      imageAsset: HanselGretelImages.page2,
    ),
    TaleSegment(
      text: 'Tam o sırada burunlarına dünyanın en güzel kokusu gelmiş: Taze kurabiye ve vanilya kokusu! Kokuyu takip ettiklerinde gözlerine inanamamışlar. Karşılarında duvarları çikolatadan, pencereleri buzlu şekerden, çatısı ise rengarenk marşmelovlardan yapılmış muhteşem bir ev duruyormuş!',
      imageAsset: HanselGretelImages.page3,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}} şaşkınlıkla, "Bu bir şaka olmalı, her yer şekerleme!" diye bağırmış. Evin kapısı yavaşça açılmış ve dışarıya üzerinde beyaz bir önlük, başında kocaman bir aşçı şapkası olan güler yüzlü, tonton bir teyze çıkmış. Bu, ormanın ünlü Pasta Ustası Şeker Hanım\'mış.',
      imageAsset: HanselGretelImages.page4,
    ),
    TaleSegment(
      text: '"Hoş geldiniz çocuklar!" demiş Şeker Hanım. "Görünüşe göre biraz yorulmuşsunuz. Haydi içeri gelin, size fırından yeni çıkmış tarçınlı çöreklerimden ikram edeyim." Hansel ve Gretel içeri girmişler. Evin içi dışından bile daha güzelmiş.',
      imageAsset: HanselGretelImages.page5,
    ),
    TaleSegment(
      text: 'Ancak Şeker Hanım biraz unutkanmış; pastalarını yaparken bazen malzemeleri karıştırıyor, bazen de fırının saatini kurmayı unutuyormuş. "Ah çocuklar," demiş, "Bugün kocaman bir meyveli pasta yapmam gerekiyor ama bütün meyvelerim bitti, malzemeleri hazırlayamıyorum!"',
      imageAsset: HanselGretelImages.page6,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}} ve Gretel hemen yardıma koşmuşlar. "Biz bugün çok güzel dağ çilekleri topladık, onları kullanabilirsin!" demiş Gretel. {{PROTAGONIST}} de mutfaktaki büyük hamuru yoğurmaya yardım etmiş. Birlikte şarkılar söyleyerek ormanın en büyük ve en renkli pastasını yapmışlar.',
      imageAsset: HanselGretelImages.page7,
    ),
    TaleSegment(
      text: 'Şeker Hanım o kadar mutlu olmuş ki, "Siz harika birer yardımcısınız!" diyerek onlara sihirli bir "Yol Bulma Haritası" hediye etmiş. Bu harita ne zaman isterseniz evinizin yolunu ışıl ışıl parlayarak gösteriyormuş.',
      imageAsset: HanselGretelImages.page8,
    ),
    TaleSegment(
      text: 'Ayrıca {{PROTAGONIST}} ve Gretel\'in ceplerini en lezzetli, diş çürütmeyen meyveli şekerlerle doldurmuş. İki kardeş haritayı takip ederek neşeyle evlerine dönmüşler. Babaları onları kapıda görünce çok sevinmişler.',
      imageAsset: HanselGretelImages.page9,
    ),
    TaleSegment(
      text: 'O günden sonra {{PROTAGONIST}} ve Gretel her hafta sonu ormana gidip Şeker Hanım\'a yeni tarifler öğretmişler. Ve her zaman şunu söylemişler: "Birlikte çalışınca, her zorluk bir şekerleme kadar tatlı olur!"',
      imageAsset: HanselGretelImages.page10,
    ),
  ],
);
