import '../ready_tale_model.dart';
import '../images/heidi_images.dart';

final ReadyTale heidi = ReadyTale(
  id: 'heidi',
  category: 'Keşif ve Macera',
  title: 'Heidi',
  defaultProtagonist: 'Heidi',
  coverAsset: HeidiImages.cover,
  segments: [
    TaleSegment(
      text: 'Bir varmış, bir yokmuş... Bulutların pamuk şeker gibi dağların tepesine konduğu, mis kokulu çiçeklerin her yeri sardığı kocaman Alp Dağları\'nda yaşayan, yanakları al al, gözleri ışıl ışıl {{PROTAGONIST}} adında bir kız varmış. {{PROTAGONIST}}, dağların en yüksek yerindeki ahşap kulübesinde tonton ve ak sakallı Büyükbabası ile birlikte yaşarmış.',
      imageAsset: HeidiImages.page1,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}} sabahları güneşle birlikte uyanır, "Günaydın güneş, günaydın çiçekler!" diye bağırarak kırlarda koşarmış. En yakın arkadaşı çoban Peter ile birlikte keçileri otlatmaya çıkar, onlara isimler takarmış. En sevdiği beyaz keçisi Pamuk, {{PROTAGONIST}} nereye gitse peşinden ayrılmazmış.',
      imageAsset: HeidiImages.page2,
    ),
    TaleSegment(
      text: 'Büyükbabası başta biraz sessiz ve ciddi bir adammış ama {{PROTAGONIST}}\'nin neşeli şarkıları ve ona her akşam getirdiği taze dağ çiçekleri sayesinde kalbi yumuşacık olmuş. Birlikte peynir yapar, akşamları yıldızları izlerlermiş.',
      imageAsset: HeidiImages.page3,
    ),
    TaleSegment(
      text: 'Bir gün {{PROTAGONIST}}, büyük şehirde yaşayan ve tekerlekli sandalye kullandığı için dışarı çıkamayan Clara adında bir kızla tanışmış. Clara biraz üzgünmüş çünkü dağların temiz havasını ve çiçeklerin kokusunu hiç bilmiyormuş. {{PROTAGONIST}} hemen elini uzatmış: "Üzülme Clara, haydi gel bizimle dağlara! Orada kuşlar sana şarkı söyler, rüzgar saçlarını tarar!" demiş.',
      imageAsset: HeidiImages.page4,
    ),
    TaleSegment(
      text: 'Clara, tekerlekli sandalyesiyle dağdaki kulübeye gelmiş. {{PROTAGONIST}} ona her gün taze süt getirmiş, Peter ona en güzel manzaraları göstermiş. Dağların o tertemiz havası ve arkadaşlarının sevgisi Clara\'ya o kadar iyi gelmiş ki, içindeki yaşama sevinci her geçen gün artmış.',
      imageAsset: HeidiImages.page5,
    ),
    TaleSegment(
      text: 'Bir gün, çimenlerin üzerinde oyun oynarken bir kelebek Clara\'nın burnuna konmuş. Clara gülümseyerek yerinden doğrulmuş ve arkadaşlarına sarılmış. Meğer sevgi ve doğa, dünyadaki en güçlü ilaçmış!',
      imageAsset: HeidiImages.page6,
    ),
    TaleSegment(
      text: '{{PROTAGONIST}}, Büyükbaba, Peter ve Clara; o yaz boyunca dağlarda hiç bitmeyen oyunlar oynamışlar. {{PROTAGONIST}} anlamış ki; paylaşılan bir dilim ekmek ve içten bir gülümseme, en yüksek dağları bile dünyanın en mutlu yerine çevirebilir.',
      imageAsset: HeidiImages.page7,
    ),
  ],
);
