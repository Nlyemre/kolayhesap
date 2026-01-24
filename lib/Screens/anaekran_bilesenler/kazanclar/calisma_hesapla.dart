// lib/Screens/anaekran_bilesenler/kazanclar/calisma_hesapla.dart
import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_gun_model.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/merkezi_hesaplama_servisi.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/girisveriler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalismaSecimDialog extends StatefulWidget {
  final TextEditingController tarihController;
  final TextEditingController notController;
  final List<String> items;
  final ValueChanged<int> onSelected;
  final VoidCallback onUpdate;
  final CalismaHesaplama calismaHesaplama;

  const CalismaSecimDialog({
    super.key,
    required this.tarihController,
    required this.notController,
    required this.items,
    required this.onSelected,
    required this.onUpdate,
    required this.calismaHesaplama,
  });

  @override
  State<CalismaSecimDialog> createState() => _CalismaSecimDialogState();
}

class _CalismaSecimDialogState extends State<CalismaSecimDialog> {
  String _yerelTarih = '';

  @override
  void initState() {
    super.initState();
    _yerelTarih = widget.tarihController.text;

    if (_yerelTarih.isEmpty) {
      _yerelTarih = DateFormat('dd-MM-yyyy').format(DateTime.now());
      widget.tarihController.text = _yerelTarih;
    }

    widget.calismaHesaplama.tarihCalisma = _yerelTarih;
  }

  void _tarihSec(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
    );
    if (pickedDate != null) {
      setState(() {
        _yerelTarih = DateFormat('dd-MM-yyyy').format(pickedDate);
        widget.tarihController.text = _yerelTarih;
      });
      widget.calismaHesaplama.tarihCalisma = _yerelTarih;
    }
  }

  Widget _buildInfoIcon(
    BuildContext context,
    String yazi, {
    double iconSize = 18,
  }) {
    return GestureDetector(
      onTap: () {
        BilgiDialog.showCustomDialog(
          context: context,
          title: 'Bilgilendirme',
          content: yazi,
          buttonText: 'Kapat',
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: Icon(
          Icons.info_outline,
          size: iconSize,
          color: Renk.pastelKoyuMavi,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Column(
          children: [
            // Tarih seçimi
            GestureDetector(
              onTap: () => _tarihSec(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: widget.tarihController,
                  style: TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Tarih',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),

            // Çalışan Tipi Seçimi
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Çalışan Tipi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  _buildInfoIcon(
                    context,
                    "Emekli misiniz yoksa normal çalışan mı? Emekliler için sigorta kesintisi %7.5, normal çalışanlar için ise %15 olarak hesaplanacaktır.",
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: Renk.pastelKoyuMavi,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.calismaHesaplama.calisanTipi =
                                widget.calismaHesaplama.calisanTipi == 'Emekli'
                                    ? 'Normal'
                                    : 'Emekli';
                          });
                          widget.calismaHesaplama.calismaListeKaydet();
                          widget.onUpdate();
                        },
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          widget.calismaHesaplama.calisanTipi,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Renk.pastelKoyuMavi,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.calismaHesaplama.calisanTipi =
                                widget.calismaHesaplama.calisanTipi == 'Normal'
                                    ? 'Emekli'
                                    : 'Normal';
                          });
                          widget.calismaHesaplama.calismaListeKaydet();
                          widget.onUpdate();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Renk.cita,
              height: 5,
              thickness: 1,
              indent: 5,
              endIndent: 5,
            ),

            // KDV Oranı Seçimi
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Vergi Oranı",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  _buildInfoIcon(
                    context,
                    "Seçtiğiniz yüzdeye göre çalışma ücretinizden KDV vergi kesintisi yapılacaktır.",
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: Renk.pastelKoyuMavi,
                        ),
                        onPressed: () {
                          if (widget.calismaHesaplama.kdvSayi > 0) {
                            setState(() {
                              widget.calismaHesaplama.kdvSayi--;
                              widget.calismaHesaplama.kdvSec.text =
                                  CalismaHesaplama.kdvListe[widget
                                      .calismaHesaplama
                                      .kdvSayi];
                              widget.calismaHesaplama.calismaKdv = double.parse(
                                MerkeziHesaplamaServisi().yuzdeAyikla(
                                  CalismaHesaplama.kdvListe[widget
                                      .calismaHesaplama
                                      .kdvSayi],
                                ),
                              );
                            });
                            widget.calismaHesaplama.calismaListeKaydet();
                            widget.onUpdate();
                          }
                        },
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          widget.calismaHesaplama.kdvSec.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Renk.pastelKoyuMavi,
                        ),
                        onPressed: () {
                          if (widget.calismaHesaplama.kdvSayi <
                              CalismaHesaplama.kdvListe.length - 1) {
                            setState(() {
                              widget.calismaHesaplama.kdvSayi++;
                              widget.calismaHesaplama.kdvSec.text =
                                  CalismaHesaplama.kdvListe[widget
                                      .calismaHesaplama
                                      .kdvSayi];

                              // HEM calismaKdv HEM de parametre olarak gelen kdvOrani güncelle
                              String ayiklanan = MerkeziHesaplamaServisi()
                                  .yuzdeAyikla(
                                    CalismaHesaplama.kdvListe[widget
                                        .calismaHesaplama
                                        .kdvSayi],
                                  );
                              widget.calismaHesaplama.calismaKdv = double.parse(
                                ayiklanan,
                              );

                              // DEBUG
                              debugPrint(
                                'KDV İleri: kdvSayi=${widget.calismaHesaplama.kdvSayi}, '
                                'Text=${widget.calismaHesaplama.kdvSec.text}, '
                                'calismaKdv=${widget.calismaHesaplama.calismaKdv}',
                              );
                            });
                            widget.calismaHesaplama.calismaListeKaydet();
                            widget.onUpdate();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            // Not Ekle alanı
            TextField(
              controller: widget.notController,
              style: TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Not Ekle',
                hintText: 'Çalışma detaylarını yazın (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 5),

            // Çalışma saat seçimi listesi
            Container(
              height: 400, // GridView için uygun yükseklik
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Her satırda 3 hücre
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1.7, // Genişlik/Yükseklik oranı
                ),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  // Örnek: "0.5 Saat Çalışma" -> "0.5 saat" şeklinde kısalt
                  final parts = item.split(' ');
                  final deger = parts.isNotEmpty ? parts[0] : '';
                  final birim = parts.length > 1 ? parts[1].toLowerCase() : '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelected(index);
                    },
                    child: CizgiliCerceve(
                      golge: 5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              deger,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(birim, style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ana CalismaHesaplama sınıfı
class CalismaHesaplama {
  // KONTROLLER
  VoidCallback? onDataChanged;
  final tarihController = TextEditingController();
  final notController = TextEditingController();

  // VERİ LİSTESİ
  List<CalismaGunModel> calismaGunleri = [];

  // VALUE NOTIFIERS
  final ValueNotifier<int> selectedIndex = ValueNotifier(0);

  // AYARLAR
  String calisanTipi = "Normal";
  double calismaKdv = 15;
  int kdvSayi = 1;

  // TARİH
  String tarihCalisma = DateFormat('dd-MM-yyyy').format(DateTime.now());
  int secilenAy = DateTime.now().month;
  int secilenYil = DateTime.now().year;

  // KONTROLLER
  final saatUcretiSec = TextEditingController();
  final gunlukUcretiSec = TextEditingController();
  final aylikUcretiSec = TextEditingController();
  final kdvSec = TextEditingController();
  final toplamCalisma = TextEditingController();
  final brutCalisma = TextEditingController();
  final netCalisma = TextEditingController();

  // SEÇİLEN DEĞER
  String secilenCalismaSaati = '0';

  // STATİK LİSTELER
  static const List<String> butonyazi = [
    'Saat Ücret',
    'Günlük Ücret',
    'Aylik Ücret',
  ];

  static const List<String> kdvListe = [
    '% 0',
    '% 15',
    '% 20',
    '% 27',
    '% 35',
    '% 40',
  ];

  static const List<String> cGunListe = ['0.5 Gün Çalışma', '1 Gün Çalışma'];

  static const List<String> cSaatListe = [
    '0.5 Saat Çalışma',
    '1 Saat Çalışma',
    '1.5 Saat Çalışma',
    '2 Saat Çalışma',
    '2.5 Saat Çalışma',
    '3 Saat Çalışma',
    '3.5 Saat Çalışma',
    '4 Saat Çalışma',
    '4.5 Saat Çalışma',
    '5 Saat Çalışma',
    '5.5 Saat Çalışma',
    '6 Saat Çalışma',
    '6.5 Saat Çalışma',
    '7 Saat Çalışma',
    '7.5 Saat Çalışma',
    '8 Saat Çalışma',
    '8.5 Saat Çalışma',
    '9 Saat Çalışma',
    '9.5 Saat Çalışma',
    '10 Saat Çalışma',
    '10.5 Saat Çalışma',
    '11 Saat Çalışma',
    '11.5 Saat Çalışma',
    '12 Saat Çalışma',
  ];

  // BAŞLANGIÇ
  Future<void> init() async {
    await calismaListeCagir();
    if (kdvSec.text.isEmpty) {
      kdvSec.text = kdvListe[kdvSayi];
    }
  }

  void dispose() {
    saatUcretiSec.dispose();
    gunlukUcretiSec.dispose();
    aylikUcretiSec.dispose();
    kdvSec.dispose();
    notController.dispose();
    toplamCalisma.dispose();
    brutCalisma.dispose();
    netCalisma.dispose();
    tarihController.dispose();
    selectedIndex.dispose();
  }

  // YARDIMCI METOTLAR
  String saatCalismaAyikla(String ayiklaiki) {
    return MerkeziHesaplamaServisi().saatCalismaAyikla(ayiklaiki);
  }

  String yuzdeAyikla(String ayiklaBir) {
    return MerkeziHesaplamaServisi().yuzdeAyikla(ayiklaBir);
  }

  double _getUcretDegeri() {
    if (selectedIndex.value == 0) {
      return double.tryParse(saatUcretiSec.text) ?? 0;
    } else if (selectedIndex.value == 1) {
      return double.tryParse(gunlukUcretiSec.text) ?? 0;
    } else {
      return double.tryParse(aylikUcretiSec.text) ?? 0;
    }
  }

  bool _tarihZatenVarMi(String tarih) {
    return calismaGunleri.any(
      (gun) => DateFormat('dd-MM-yyyy').format(gun.tarih) == tarih,
    );
  }

  Future<void> listeyiGuncelle({
    required String islem,
    int? index,
    required double kdvOrani,
    required String calisanTipi,
    required bool besAktif,
    required double besOrani,
  }) async {
    // SİLME İŞLEMİ - SAAT KONTROLÜ YAPMA
    if (islem == "sil" && index != null) {
      if (index >= 0 && index < calismaGunleri.length) {
        calismaGunleri.removeAt(index);
        await calismaListeKaydet();
        notController.clear();
        hesaplaToplamlar();
        onDataChanged?.call();

        debugPrint(
          'listeyiGuncelle (sil) tamamlandı. Liste uzunluğu: ${calismaGunleri.length}',
        );
      }
      return; // Silme işlemi tamamlandı, saat kontrolü yapmadan devam
    }

    // EKLEME VE DÜZENLEME İŞLEMLERİ - SAAT KONTROLÜ YAP
    final deger =
        double.tryParse(saatCalismaAyikla(secilenCalismaSaati)) ?? 0.0;
    if (deger <= 0) {
      debugPrint('Geçersiz çalışma süresi: $secilenCalismaSaati');
      return;
    }

    final ucret = _getUcretDegeri();
    if (ucret <= 0) {
      debugPrint('Ücret bilgisi girilmemiş veya sıfır');
      return;
    }

    // === DEBUG: YIL KONTROLÜ ===
    debugPrint('=== CalismaHesaplama.listeyiGuncelle ===');
    debugPrint('İşlem: $islem');
    debugPrint('Tarih: $tarihCalisma');

    // 2. TARİHİ AYIKLA ve YILI GÜNCELLE
    DateTime tarih;
    try {
      tarih = DateFormat('dd-MM-yyyy').parse(tarihCalisma);

      // YILI GÜNCELLE - ÇOK ÖNEMLİ!
      GirisVerileriManager.seciliYil = tarih.year;
      debugPrint('Tarih parse edildi: $tarih');
      debugPrint('Yıl güncellendi: ${tarih.year}');
    } catch (e) {
      debugPrint('Tarih parse hatası: $e');
      tarih = DateTime.now();
      GirisVerileriManager.seciliYil = DateTime.now().year;
      debugPrint('Varsayılan tarih kullanıldı: $tarih');
    }

    // 3. BRUT HESAPLA - MERKEZİ SERVİS KULLAN
    double calismaBrut = MerkeziHesaplamaServisi().calismaBrutHesapla(
      calismaSaati: deger,
      kaydedilenIndex: selectedIndex.value,
      kaydedilenUcret: ucret,
    );

    // 4. NET HESAPLA - MERKEZİ SERVİS KULLAN
    Map<String, double> bordro = MerkeziHesaplamaServisi().hesapBordro(
      brut: calismaBrut,
      calisanTipi: calisanTipi,
      vergiOrani: kdvOrani,
      tarih: tarih,
      calismaGunSayisi: 1,
    );

    // 5. BES KESİNTİSİ - MERKEZİ SERVİS KULLAN
    double besKesintisi = MerkeziHesaplamaServisi().besKesintisiHesapla(
      brut: calismaBrut,
      besAktif: besAktif,
      besOrani: besOrani,
    );

    // 6. NET HESAPLA
    double net = (bordro['net'] ?? 0) - besKesintisi;

    // 7. YENİ GÜN MODELİ OLUŞTUR
    final birim = selectedIndex.value == 0 ? "Saat" : "Gün";
    final yeniGun = CalismaGunModel(
      tarih: tarih,
      calistiMi: true,
      calismaSaati: deger,
      calismaMetni:
          "- $tarihCalisma Tarihinde ${deger.toStringAsFixed(2)} $birim Çalışma",
      calismaNet: net,
      calismaBrut: calismaBrut,
      calismaNotu: notController.text.isNotEmpty ? notController.text : null,
      toplamKazanc: net,
      toplamBrut: calismaBrut,
      kaydedilenIndex: selectedIndex.value,
      kaydedilenUcret: ucret,
      kaydedilenCalisanTipi: calisanTipi,
      kaydedilenKdvOrani: kdvOrani,
      kaydedilenBesOrani: besOrani,
      kaydedilenBesAktif: besAktif,
      agiIstisnasi: bordro['agi'] ?? 0,
      damgaIstisnasi: bordro['damgaIstisnasi'] ?? 0,
    );

    // 8. LİSTEYİ GÜNCELLE
    switch (islem) {
      case "ekle":
        calismaGunleri.insert(0, yeniGun);
        break;
      case "duzenle":
        if (index != null && index >= 0 && index < calismaGunleri.length) {
          calismaGunleri[index] = yeniGun;
        }
        break;
      case "sil":
        // Silme işlemi yukarıda zaten yapıldı
        break;
    }

    // 9. KAYDET VE BİLDİR (sadece ekleme ve düzenleme için)
    if (islem != "sil") {
      await calismaListeKaydet();
      notController.clear();
      hesaplaToplamlar();
      onDataChanged?.call();
    }
  }

  // TOPLAM HESAPLAMA
  void hesaplaToplamlar() {
    double toplamC = calismaGunleri.fold(
      0.0,
      (sum, gun) => sum + gun.calismaSaati,
    );
    double toplamBrutDeger = calismaGunleri.fold(
      0.0,
      (sum, gun) => sum + gun.calismaBrut,
    );
    double toplamNetDeger = calismaGunleri.fold(
      0.0,
      (sum, gun) => sum + gun.calismaNet,
    );

    toplamCalisma.text = toplamC.toStringAsFixed(2);
    brutCalisma.text = toplamBrutDeger.toStringAsFixed(2);
    netCalisma.text = toplamNetDeger.toStringAsFixed(2);
  }

  // KAYDETME
  Future<void> calismaListeKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final int index = selectedIndex.value;
    final int yil = secilenYil;
    final int ay = secilenAy;

    // AYARLARI KAYDET - calismaKdv'yi int olarak kaydetme, sadece index'i kaydet
    await prefs.setInt('index', index);
    await prefs.setString('calisanTipi', calisanTipi);
    await prefs.setDouble('$index-$yil-$ay-saatUcreti', _getUcretDegeri());
    await prefs.setInt(
      '$index-$yil-$ay-calismaKdvSayi',
      kdvSayi,
    ); // SADECE index'i kaydet

    debugPrint('KDV Kaydet: kdvSayi=$kdvSayi, calismaKdv=$calismaKdv');

    // LİSTEYİ KAYDET
    await prefs.setString(
      '$index-$yil-$ay-calismaGunleri',
      jsonEncode(calismaGunleri.map((g) => g.toJson()).toList()),
    );

    // TOPLAMLARI KAYDET
    hesaplaToplamlar();
    await prefs.setDouble(
      '$index-$yil-$ay-calismaSaat',
      double.parse(toplamCalisma.text),
    );
    await prefs.setDouble(
      '$index-$yil-$ay-calismaBurut',
      double.parse(brutCalisma.text),
    );
    await prefs.setDouble(
      '$index-$yil-$ay-calismaNet',
      double.parse(netCalisma.text),
    );
  }

  Future<void> calismaListeCagir() async {
    final prefs = await SharedPreferences.getInstance();
    calisanTipi = prefs.getString('calisanTipi') ?? "Normal";

    final int savedIndex = prefs.getInt('index') ?? 0;
    selectedIndex.value = savedIndex;
    final int index = savedIndex;
    double saatUcretiYukle =
        prefs.getDouble('$index-$secilenYil-$secilenAy-saatUcreti') ?? 0.0;
    int kdvSayiValue =
        prefs.getInt('$index-$secilenYil-$secilenAy-calismaKdvSayi') ?? 1;

    // KDV SAYISINDAN ORANI HESAPLA
    kdvSayi = kdvSayiValue.clamp(0, kdvListe.length - 1);
    kdvSec.text = kdvListe[kdvSayi];

    // calismaKdv'yi metinden al, SharedPreferences'tan değil
    String ayiklananYuzde = yuzdeAyikla(kdvListe[kdvSayi]);
    calismaKdv = double.tryParse(ayiklananYuzde) ?? 15.0;

    debugPrint(
      'KDV Yükleme - kdvSayi: $kdvSayi, Text: ${kdvSec.text}, calismaKdv: $calismaKdv',
    );

    // CONTROLLER'LARI GÜNCELLE
    if (index == 0) {
      saatUcretiSec.text =
          saatUcretiYukle > 0 ? saatUcretiYukle.toStringAsFixed(2) : "";
      gunlukUcretiSec.clear();
      aylikUcretiSec.clear();
    } else if (index == 1) {
      gunlukUcretiSec.text =
          saatUcretiYukle > 0 ? saatUcretiYukle.toStringAsFixed(2) : "";
      saatUcretiSec.clear();
      aylikUcretiSec.clear();
    } else {
      aylikUcretiSec.text =
          saatUcretiYukle > 0 ? saatUcretiYukle.toStringAsFixed(2) : "";
      saatUcretiSec.clear();
      gunlukUcretiSec.clear();
    }

    // LİSTEYİ YÜKLE
    final String gunlerKey = '$index-$secilenYil-$secilenAy-calismaGunleri';
    final String? gunlerJson = prefs.getString(gunlerKey);

    if (gunlerJson != null && gunlerJson.isNotEmpty && gunlerJson != '[]') {
      try {
        List<dynamic> decoded = jsonDecode(gunlerJson);
        calismaGunleri =
            decoded.map((json) => CalismaGunModel.fromJson(json)).toList();
        calismaGunleri.sort((a, b) => b.tarih.compareTo(a.tarih));
      } catch (e) {
        debugPrint('Çalışma listesi yükleme hatası: $e');
        calismaGunleri = [];
      }
    } else {
      calismaGunleri = [];
    }

    hesaplaToplamlar();
  }

  Future<void> calismaEkleDialog(
    BuildContext context, {
    required VoidCallback onUpdate,
    required double kdvOrani,
    required String calisanTipi,
    required bool besAktif,
    required double besOrani,
  }) async {
    // DETAYLI ÜCRET KONTROLÜ
    String ucretHatasi = '';

    if (selectedIndex.value == 0 &&
        (saatUcretiSec.text.isEmpty ||
            double.tryParse(saatUcretiSec.text) == 0)) {
      ucretHatasi = 'Saat ücreti giriniz';
    } else if (selectedIndex.value == 1 &&
        (gunlukUcretiSec.text.isEmpty ||
            double.tryParse(gunlukUcretiSec.text) == 0)) {
      ucretHatasi = 'Günlük ücret giriniz';
    } else if (selectedIndex.value == 2 &&
        (aylikUcretiSec.text.isEmpty ||
            double.tryParse(aylikUcretiSec.text) == 0)) {
      ucretHatasi = 'Aylık ücret giriniz';
    }

    if (ucretHatasi.isNotEmpty) {
      Mesaj.altmesaj(context, ucretHatasi, Colors.red);
      return;
    }

    // KONTROL: ÜCRET DEĞERİNİN GEÇERLİLİĞİ
    double ucret = _getUcretDegeri();
    if (ucret <= 0) {
      Mesaj.altmesaj(context, 'Geçerli bir ücret giriniz!', Colors.red);
      return;
    }

    if (tarihController.text.isEmpty) {
      tarihController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      tarihCalisma = tarihController.text;
    }

    if (_tarihZatenVarMi(tarihCalisma)) {
      Mesaj.altmesaj(
        context,
        'Bu tarihte zaten çalışma kaydı var! Düzenlemek için mevcut kaydı seçin.',
        Colors.red,
      );
      return;
    }

    notController.clear();
    await calismaSaatSecDialog(
      context,
      onUpdate: onUpdate,
      kdvOrani: kdvOrani,
      calisanTipi: calisanTipi,
      besAktif: besAktif,
      besOrani: besOrani,
    );
  }

  Future<void> calismaSaatSecDialog(
    BuildContext context, {
    required VoidCallback onUpdate,
    required double kdvOrani,
    required String calisanTipi,
    required bool besAktif,
    required double besOrani,
    bool isDuzenleme = false,
    int? duzenlenecekIndex,
  }) async {
    if (tarihController.text.isEmpty) {
      tarihController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }

    final items = selectedIndex.value == 0 ? cSaatListe : cGunListe;

    await AcilanPencere.show(
      context: context,
      title:
          selectedIndex.value == 0
              ? 'Çalışma Saati Seçiniz'
              : 'Çalışma Günü Seçiniz',
      height: 0.95,
      content: CalismaSecimDialog(
        calismaHesaplama: this,
        tarihController: tarihController,
        notController: notController,
        items: items,
        onSelected: (index) async {
          secilenCalismaSaati = items[index];
          tarihCalisma = tarihController.text;

          await listeyiGuncelle(
            islem: isDuzenleme ? "duzenle" : "ekle",
            index: duzenlenecekIndex,
            kdvOrani: kdvOrani,
            calisanTipi: calisanTipi,
            besAktif: besAktif,
            besOrani: besOrani,
          );

          Mesaj.altmesaj(
            // ignore: use_build_context_synchronously
            context,
            isDuzenleme
                ? "$secilenCalismaSaati güncellendi"
                : "$secilenCalismaSaati eklendi",
            Colors.green,
          );
          onUpdate();
        },
        onUpdate: onUpdate,
      ),
    );
  }

  Future<void> duzenleCalismaDialog(
    BuildContext context,
    int index, {
    required VoidCallback onUpdate,
    required double kdvOrani,
    required String calisanTipi,
    required bool besAktif,
    required double besOrani,
  }) async {
    if (index < 0 || index >= calismaGunleri.length) return;

    final gun = calismaGunleri[index];
    final eskitarih = DateFormat('dd-MM-yyyy').format(gun.tarih);

    tarihController.text = eskitarih;
    notController.text = gun.calismaNotu ?? "";

    // Çalışan tipi ve KDV'yi yükle
    this.calisanTipi = gun.kaydedilenCalisanTipi ?? calisanTipi;
    calismaKdv = gun.kaydedilenKdvOrani ?? kdvOrani;

    // KDV sayısını güncelle
    kdvSayi = CalismaHesaplama.kdvListe.indexWhere(
      (item) => item.contains(calismaKdv.toString()),
    );
    if (kdvSayi == -1) kdvSayi = 1;
    kdvSec.text = CalismaHesaplama.kdvListe[kdvSayi];

    await AcilanPencere.show(
      context: context,
      title: 'Çalışma Saati Düzenle',
      height: 0.95,
      content: CalismaSecimDialog(
        calismaHesaplama: this,
        notController: notController,
        tarihController: tarihController,
        items: selectedIndex.value == 0 ? cSaatListe : cGunListe,
        onSelected: (listIndex) async {
          final yeniTarih = tarihController.text;

          if (yeniTarih != eskitarih && _tarihZatenVarMi(yeniTarih)) {
            Mesaj.altmesaj(
              context,
              '$yeniTarih tarihinde zaten çalışma kaydı var! Farklı bir tarih seçin.',
              Colors.red,
            );
            return;
          }

          tarihCalisma = yeniTarih;
          secilenCalismaSaati =
              selectedIndex.value == 0
                  ? cSaatListe[listIndex]
                  : cGunListe[listIndex];
          await listeyiGuncelle(
            islem: "duzenle",
            index: index,
            kdvOrani: kdvOrani,
            calisanTipi: calisanTipi,
            besAktif: besAktif,
            besOrani: besOrani,
          );
          // ignore: use_build_context_synchronously
          Mesaj.altmesaj(context, "Çalışma Güncellendi", Colors.green);
          onUpdate();
        },
        onUpdate: onUpdate,
      ),
    );
  }

  Future<void> silCalismaDialog(
    BuildContext context,
    int index, {
    required VoidCallback onUpdate,
  }) async {
    if (index < 0 || index >= calismaGunleri.length) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Çalışma Kaydını Sil'),
            content: Text(
              '${DateFormat('dd-MM-yyyy').format(calismaGunleri[index].tarih)} tarihli çalışma kaydını silmek istiyor musunuz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await listeyiGuncelle(
        islem: "sil",
        index: index,
        kdvOrani: calismaGunleri[index].kaydedilenKdvOrani ?? 15,
        calisanTipi: calismaGunleri[index].kaydedilenCalisanTipi ?? "Normal",
        besAktif: calismaGunleri[index].kaydedilenBesAktif ?? false,
        besOrani: calismaGunleri[index].kaydedilenBesOrani ?? 0,
      );

      // ignore: use_build_context_synchronously
      Mesaj.altmesaj(context, "Çalışma kaydı silindi", Colors.green);
      onUpdate();
    }
  }

  // GETTER'LAR
  ValueNotifier<List<String>> get calismaMetinListe {
    return ValueNotifier(
      calismaGunleri.map((gun) => gun.calismaMetni).toList(),
    );
  }

  List<String> get calismaNotListe {
    return calismaGunleri.map((gun) => gun.calismaNotu ?? "").toList();
  }
}
