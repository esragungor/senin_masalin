import '../ready_tale_model.dart';
import '../images/robin_hood_images.dart';

final ReadyTale robinHood = ReadyTale(
  id: 'robin_hood',
  category: 'Keşif ve Macera',
  title: 'Robin Hood',
  defaultProtagonist: 'Robin Hood',
  coverAsset: RobinHoodImages.cover,
  segments: [
    TaleSegment(
      text: 'Bir varmış, bir yokmuş... Gökyüzüne uzanan devasa meşe ağaçlarının, şırıl şırıl akan derelerin ve rengarenk kuşların olduğu kocaman bir Sherwood Ormanı varmış. Bu ormanın kalbinde, yeşil kıyafetleri ve her zaman gülen yüzüyle {{PROTAGONIST}} adında çok zeki bir genç yaşarmış.',
      imageAsset: RobinHoodImages.page1,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}}’un harika bir ekibi varmış: Kocaman göbeğiyle şakalar yapan Küçük John, çok güzel şarkılar söyleyen Ozan Will ve herkese lezzetli yemekler pişiren Aşçı Marian. Bu ekip, ormanın derinliklerinde ağaç evlerde yaşar ve birbirlerine her konuda destek olurlarmış.',
      imageAsset: RobinHoodImages.page2,
    ),
    TaleSegment(
      text: 'O günlerde yakındaki kasabada, her şeyi sadece kendisi için isteyen ve oyunlarda mızıkçılık yapan Şerif adında bir adam yaşarmış. Şerif, kasabadaki çocukların bütün oyuncaklarını toplamış ve onlara dondurma yemeyi yasaklamış! "Hepsi benim olmalı!" diyerek her şeyi şatosuna kilitlemiş.',
      imageAsset: RobinHoodImages.page3,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}} bunu duyunca, "Bu hiç adil değil! Oyunlar ve dondurmalar herkes içindir," demiş. Hemen bir plan yapmış.',
      imageAsset: RobinHoodImages.page4,
    ),
    TaleSegment(
      text: 'Bir gün kasabada büyük bir "Hedef Vurma Yarışması" düzenlenmiş. Ödül ise kocaman bir sandık dolusu elmalı şeker ve yeni oyuncaklarmış. {{PROTAGONIST}}, başına takma bir şapka ve gözlük takarak yarışmaya katılmış. Şerif kendi oklarını fırlatmış ama {{PROTAGONIST}}, elindeki oyuncak yayıyla tam merkeze; yani sevgi dolu kalbe isabet ettirmiş!',
      imageAsset: RobinHoodImages.page5,
    ),
    TaleSegment(
      text: 'TIIINNN! {{PROTAGONIST}} ödülü kazanmış! Ama ödülü alıp kaçmamış. Şerif\'in yanına gitmiş ve gülümseyerek: "Bak Şerif dostum, bu kadar çok oyuncağı tek başına oynamak çok sıkıcı değil mi? Gel, bu sandığı kasabadaki tüm çocuklarla paylaşalım. Birlikte oynamak, tek başına sahip olmaktan çok daha eğlencelidir!" demiş.',
      imageAsset: RobinHoodImages.page6,
    ),
    TaleSegment(
      text: 'Şerif önce şaşırmış, sonra Robin\'in ve çocukların gözlerindeki o heyecanı görmüş. Kalbindeki o asık suratlılık bir anda uçup gitmiş. "Haklısın Robin," demiş. "Tek başıma oynarken hiç kimseyle gülemiyordum."',
      imageAsset: RobinHoodImages.page7,
    ),
    TaleSegment(
      text: 'Şerif şatosunun kapılarını açmış. {{PROTAGONIST}} ve ekibi, çocuklara oyuncaklarını geri dağıtmışlar. O akşam Sherwood Ormanı\'nın kıyısında dev bir Paylaşım Partisi düzenlenmiş. {{PROTAGONIST}} okçuluk gösterileri yapmış, Küçük John taklalar atmış, Şerif ise çocuklara en büyük dondurma külahlarını hazırlamış.',
      imageAsset: RobinHoodImages.page8,
    ),
    TaleSegment(
      text: 'O günden sonra Sherwood Ormanı\'nda kimse eşyasını saklamamış. {{PROTAGONIST}} ise ormanın koruyucusu olarak kalmış ve herkese şunu hatırlatmış: "En büyük zenginlik, paylaştığın dostların ve yüzündeki gülümsemedir!"',
      imageAsset: RobinHoodImages.page9,
    ),
  ],
);
