/// Tüm hazır masalların merkezi kayıt dosyası.
///
/// Yeni bir masal eklediğinde:
/// 1. Masal dosyasını tales/ klasörüne oluştur
/// 2. Bu dosyaya import et
/// 3. allTales listesine ekle

import 'ready_tale_model.dart';

// --- Masal İçe Aktarmaları ---
import 'tales/kirmizi_baslikli_kiz.dart';
import 'tales/yalanci_coban.dart';
import 'tales/pinokyo.dart';
import 'tales/altin_sacli_kiz.dart';
import 'tales/kucuk_kirmizi_tavuk.dart';
import 'tales/kralin_gorunmez_kiyafetleri.dart';
import 'tales/uyuyan_guzel.dart';
import 'tales/uyku_perisi.dart';
import 'tales/parmak_kiz.dart';
import 'tales/kucuk_prens.dart';
import 'tales/yildiz_cocuk.dart';
import 'tales/neseli_papatya.dart';
import 'tales/zencefilli_kurabiye.dart';
import 'tales/dev_salgam.dart';
import 'tales/saskin_hans.dart';
import 'tales/sihirli_tencere.dart';
import 'tales/uc_dilek.dart';
import 'tales/keloglan_sihirli_tas.dart';
import 'tales/bremen_mizikacilari.dart';
import 'tales/boz_tuy_ordek.dart';
import 'tales/karinca_agustos_bocegi.dart';
import 'tales/uc_kucuk_domuzcuk.dart';
import 'tales/tavsan_kaplumbaga.dart';
import 'tales/aslan_ile_fare.dart';
import 'tales/kursun_asker.dart';
import 'tales/peter_pan.dart';
import 'tales/jack_fasulye_sirigi.dart';
import 'tales/cesur_terzi.dart';
import 'tales/denizci_sindbad.dart';
import 'tales/findikkiran.dart';
import 'tales/belle_sato_gizemi.dart';
import 'tales/kibritci_kiz.dart';
import 'tales/neseli_prens.dart';
import 'tales/pamuk_prenses.dart';
import 'tales/kocaman_dev.dart';
import 'tales/ayakkabici_elfler.dart';
import 'tales/sindirella.dart';
import 'tales/karlar_kralicesi.dart';
import 'tales/kurbaga_prens.dart';
import 'tales/alaaddin.dart';
import 'tales/kugu_golu.dart';
import 'tales/pofuduk_bilmececi.dart';
import 'tales/cizmeli_kedi.dart';
import 'tales/ali_baba_haramiler.dart';
import 'tales/hansel_gretel.dart';
import 'tales/keloglan_bilmece.dart';
import 'tales/tilki_ile_leylek.dart';
import 'tales/karga_gakgak_tilki.dart';
import 'tales/alice_harikalar.dart';
import 'tales/oz_buyucusu.dart';
import 'tales/mowgli_orman_sarkisi.dart';
import 'tales/heidi.dart';
import 'tales/gulliver.dart';
import 'tales/robin_hood.dart';
import 'tales/rapunzel.dart';
import 'tales/on_iki_dans_eden_prenses.dart';
import 'tales/prenses_ve_bezelye_tanesi.dart';
import 'tales/kucuk_deniz_kizi.dart';
import 'tales/prenses_ve_akilli_kazlar.dart';
import 'tales/eliza_ve_on_bir_gumus_kugu.dart';
























class ReadyTalesRegistry {
  /// Uygulamadaki tüm hazır masallar burada listelenir
  static final List<ReadyTale> allTales = [
    kirmiziBashlikliKiz,
    yalanciCoban,
    pinokyo,
    altinSacliKiz,
    kucukKirmiziTavuk,
    kralinGorunmezKiyafetleri,
    uyuyanGuzel,
    uykuPerisi,
    parmakKiz,
    kucukPrens,
    yildizCocuk,
    neseliPapatya,
    zencefilliKurabiye,
    devSalgam,
    saskinHans,
    sihirliTencere,
    ucDilek,
    keloglanSihirliTas,
    bremenMizikacilari,
    bozTuyOrdek,
    karincaAgustosBocegi,
    ucKucukDomuzcuk,
    tavsanKaplumbaga,
    aslanIleFare,
    kursunAsker,
    peterPan,
    jackFasulyeSirigi,
    cesurTerzi,
    denizciSindbad,
    findikkiran,
    belleSatoGizemi,
    kibritciKiz,
    neseliPrens,
    pamukPrenses,
    kocamanDev,
    ayakkabiciElfler,
    sindirella,
    karlarKralicesi,
    kurbagaPrens,
    alaaddin,
    kuguGolu,
    pofudukBilmececi,
    cizmeliKedi,
    aliBabaHaramiler,
    hanselGretel,
    keloglanBilmece,
    tilkiIleLeylek,
    kargaGakgakTilki,
    aliceHarikalar,
    ozBuyucusu,
    mowgliOrmanSarkisi,
    heidi,
    gulliver,
    robinHood,
    rapunzel,
    onIkiDansEdenPrenses,
    prenses_ve_bezelye_tanesi,
    kucukDenizKizi,
    prenses_ve_akilli_kazlar,
    elizaVeGumusKugu,






    

















  ];

  /// Kategorilere göre gruplanmış masalları döndürür
  static Map<String, List<ReadyTale>> getGroupedTales() {
    final Map<String, List<ReadyTale>> grouped = {};
    for (var tale in allTales) {
      final category = tale.category;
      grouped.putIfAbsent(category, () => []).add(tale);
    }
    return grouped;
  }
}
