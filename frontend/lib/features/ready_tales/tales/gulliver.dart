import '../ready_tale_model.dart';
import '../images/gulliver_images.dart';

final ReadyTale gulliver = ReadyTale(
  id: 'gulliver',
  category: 'Keşif ve Macera',
  title: 'Gulliver ve Minik Dostlar Ülkesi',
  defaultProtagonist: 'Gulliver',
  coverAsset: GulliverImages.cover,
  segments: [
    TaleSegment(
      text: 'Bir varmış, bir yokmuş... Denizleri, dalgaları ve yeni yerler keşfetmeyi çok seven {{PROTAGONIST}} adında meraklı bir gezgin varmış. Bir gün fırtınalı bir yolculuğun ardından, {{PROTAGONIST}} kendini kumsalı bembeyaz kumlarla kaplı, hiç bilmediği bir adada bulmuş.',
      imageAsset: GulliverImages.page1,
    ),
    TaleSegment(
      text: 'Yorgunluktan kumsalda uyuyakalmış. Uyandığında ise bir gariplik fark etmiş; etrafında parmak boyunda, minicik insanlar heyecanla koşuşturuyormuş! Evler kutu kadar, ağaçlar ise maydanoz dalı kadarmış. Burası meşhur Lilliput, yani Cüceler Ülkesi\'ymiş.',
      imageAsset: GulliverImages.page2,
    ),
    TaleSegment(
      text: 'Minik insanlar önce {{PROTAGONIST}}’den biraz çekinmişler. "Bu dev adam da kim? Acaba bize zarar verir mi?" diye fısıldaşmışlar. Ama {{PROTAGONIST}} onlara en tatlı gülümsemesiyle bakmış ve "Merhaba minik dostlarım, ben sadece bir gezginim ve sizinle arkadaş olmak istiyorum," demiş.',
      imageAsset: GulliverImages.page3,
    ),
    TaleSegment(
      text: 'Cüceler, {{PROTAGONIST}}’in ne kadar nazik olduğunu görünce hemen ona bir ziyafet hazırlamışlar. Ama {{PROTAGONIST}} o kadar büyükmüş ki, cücelerin binlerce minik ekmeği ve fındık kadar elmaları ancak onun bir lokması ediyormuş! {{PROTAGONIST}} onlara teşekkür etmiş ve "Merak etmeyin, ben de size yardım edeceğim," demiş.',
      imageAsset: GulliverImages.page4,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}} kısa sürede adanın en sevilen kahramanı olmuş: Bir gün, cücelerin en yüksek kulesinin tepesindeki bayrak takılınca, {{PROTAGONIST}} parmağıyla uzanıp onu düzeltivermiş. Başka bir gün, cücelerin bahçesindeki dev bir kaya (aslında {{PROTAGONIST}} için küçük bir taş) yolu kapatınca, {{PROTAGONIST}} onu bir parmağıyla kenara itmiş.',
      imageAsset: GulliverImages.page5,
    ),
    TaleSegment(
      text: 'Bir gün komşu adadan bir grup gemi, cücelerin kıyılarına oyun oynamak ve şaka yapmak için yaklaşmış. Cüceler biraz endişelenmiş. {{PROTAGONIST}} hemen denize girmiş (su ancak dizine geliyormuş!) ve gemilerin iplerini nazikçe tutup onları durdurmuş. "Hey dostlar!" demiş, "Kavga etmek yerine gelin hep birlikte kıyıda bir kum kalesi yapalım!"',
      imageAsset: GulliverImages.page6,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}}’in bu barışçıl tavrı herkesi çok mutlu etmiş. İki adanın cüceleri el ele tutuşup dev bir dostluk halkası kurmuşlar. {{PROTAGONIST}} onlara dev parmaklarıyla minicik oyuncaklar yapmış, cüceler de {{PROTAGONIST}}’e dünyanın en rahat yatağını hazırlamışlar.',
      imageAsset: GulliverImages.page7,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}} artık gitme vaktinin geldiğini anladığında, cüceler ona veda etmek için sahilde toplanmışlar. {{PROTAGONIST}}, "Sizden çok şey öğrendim," demiş. "Önemli olan boyumuzun ne kadar büyük olduğu değil, kalbimizin ne kadar geniş olduğudur."',
      imageAsset: GulliverImages.page8,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}} yelkenlerini açıp uzaklaşırken, minik dostları sahilde "Güle güle Nazik Dev!" diye el sallamışlar. {{PROTAGONIST}} ise o minik adayı ve o koca yürekli dostlarını hayatı boyunca hiç unutmamış.',
      imageAsset: GulliverImages.page9,
    ),
  ],
);
