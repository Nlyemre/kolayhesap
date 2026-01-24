// lib/Screens/anaekran_bilesenler/kazanclar/widgets/isci_takvim_widget.dart
import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/kazanclar/app_data.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_gun_model.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/calisma_hesapla.dart';
import 'package:app/Screens/anaekran_bilesenler/kazanclar/data_servisi.dart';
import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesaihesapla.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mesai_secenekler.dart';

class IsciTakvimWidget extends StatefulWidget {
  final VoidCallback? onKazancChanged;
  final VoidCallback? onGunlerChanged;
  final DataServisi? dataServisi;

  const IsciTakvimWidget({
    super.key,
    this.onKazancChanged,
    this.onGunlerChanged,
    this.dataServisi,
  });

  @override
  State<IsciTakvimWidget> createState() => IsciTakvimWidgetState();
}

class IsciTakvimWidgetState extends State<IsciTakvimWidget> {
  DateTime seciliAy = DateTime.now();
  late AppData appData;
  late CalismaHesaplama calismaHesaplama;
  late MesaiHesaplama mesaiHesaplama;
  bool veriYuklendi = false;
  bool gorunumModu = true;
  final ValueNotifier<List<CalismaGunModel>> gunlerNotifier =
      ValueNotifier<List<CalismaGunModel>>([]);
  late PageController pageController;
  final ValueNotifier<int> selectedIndex = ValueNotifier(0);
  String calisanTipi = "Normal";

  DataServisi get _dataServisi {
    return widget.dataServisi ?? DataServisi();
  }

  double get _kdvOrani => calismaHesaplama.calismaKdv;
  String get _calisanTipi => calisanTipi;
  bool get _besAktif => _dataServisi.besAktif;
  double get _besOrani => _dataServisi.besOrani;

  @override
  void initState() {
    super.initState();
    debugPrint('=== İŞÇİ TAKVİM WIDGET BAŞLATILIYOR ===');

    pageController = PageController(viewportFraction: 0.33, initialPage: 0);

    // Verileri hemen yükle, postFrameCallback'e beklemeden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _baslangicVerileriniYukle();
    });
  }

  Future<void> _baslangicVerileriniYukle() async {
    try {
      debugPrint('Başlangıç verileri yükleniyor...');

      if (widget.dataServisi != null) {
        appData = widget.dataServisi!.appData;
        calismaHesaplama = widget.dataServisi!.calismaHesaplama;
        mesaiHesaplama = widget.dataServisi!.mesaiHesaplama;

        // === ÇALIŞMA VE MESAI VERİLERİNİ HEMEN YÜKLE! ===
        await calismaHesaplama.calismaListeCagir();
        await mesaiHesaplama.init();
        await uyarilariYukle();

        debugPrint(
          'CalismaGunleri yüklendi: ${calismaHesaplama.calismaGunleri.length} kayıt',
        );
        debugPrint(
          'Mesai kayıtları yüklendi: ${mesaiHesaplama.mesaiMetinListe.value.length} kayıt',
        );
      }

      // 500ms BEKLE SONRA GÜNCELLE
      await Future.delayed(const Duration(milliseconds: 500));
      await _guncelleTakvimVerileri();

      if (mounted) {
        setState(() {
          veriYuklendi = true;
        });

        debugPrint(
          "Tüm başlangıç işlemleri bitti → grafik şimdi TEK KEZ çağrılıyor",
        );
        widget.onKazancChanged?.call();
      }

      debugPrint('Başlangıç verileri yüklendi');
    } catch (e) {
      debugPrint('!!! Başlangıç veri yükleme hatası: $e');
      if (mounted) {
        setState(() {
          veriYuklendi = true;
        });
      }
    }
  }

  @override
  void dispose() {
    gunlerNotifier.dispose();
    selectedIndex.dispose();
    pageController.dispose();
    super.dispose();
  }

  // TAKVİM VERİLERİNİ GÜNCELLE
  Future<void> _guncelleTakvimVerileri() async {
    try {
      debugPrint('Takvim verileri güncelleniyor: ${selectedIndex.value}');

      await mesaiHesaplama.mesaiListeCagir();

      // ✅ FİLTRELİ KULLANIM - SADECE SEÇİLİ INDEX'İ GÖSTER
      await appData.verileriBirlestirFiltreli(
        calisanTipi: calisanTipi,
        kdvOrani: calismaHesaplama.calismaKdv,
        besOrani: _besOrani,
        besAktif: _besAktif,
        mesaiVerileriniDahilEt: true,
        selectedIndex: selectedIndex.value, // SADECE BU INDEX
      );

      await ayiYukle();
    } catch (e) {
      debugPrint('!!! Takvim güncelleme hatası: $e');
    }
  }

  Future<void> uyarilariYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final int yil = seciliAy.year;
    final int ay = seciliAy.month;
    final int currentIndex = calismaHesaplama.selectedIndex.value;

    double saat = prefs.getDouble('0-$yil-$ay-saatUcreti') ?? 0.0;
    double gunluk = prefs.getDouble('1-$yil-$ay-saatUcreti') ?? 0.0;
    double aylik = prefs.getDouble('2-$yil-$ay-saatUcreti') ?? 0.0;

    calismaHesaplama.saatUcretiSec.text = saat.toStringAsFixed(2);
    calismaHesaplama.gunlukUcretiSec.text = gunluk.toStringAsFixed(2);
    calismaHesaplama.aylikUcretiSec.text = aylik.toStringAsFixed(2);

    final int kdvIndex =
        prefs.getInt('$currentIndex-$yil-$ay-calismaKdvSayi') ?? 1;
    calismaHesaplama.kdvSayi = kdvIndex;
    calismaHesaplama.kdvSec.text = CalismaHesaplama.kdvListe[kdvIndex];

    if (mounted) setState(() {});
  }

  Future<void> uyarilariKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final int yil = seciliAy.year;
    final int ay = seciliAy.month;

    prefs.setDouble(
      '0-$yil-$ay-saatUcreti',
      double.tryParse(calismaHesaplama.saatUcretiSec.text) ?? 0.0,
    );
    prefs.setDouble(
      '1-$yil-$ay-saatUcreti',
      double.tryParse(calismaHesaplama.gunlukUcretiSec.text) ?? 0.0,
    );
    prefs.setDouble(
      '2-$yil-$ay-saatUcreti',
      double.tryParse(calismaHesaplama.aylikUcretiSec.text) ?? 0.0,
    );

    final int currentIndex = calismaHesaplama.selectedIndex.value;
    final String kdvAnahtari = '$currentIndex-$yil-$ay-calismaKdvSayi';
    prefs.setInt(kdvAnahtari, calismaHesaplama.kdvSayi);
    calismaHesaplama.kdvSec.text =
        CalismaHesaplama.kdvListe[calismaHesaplama.kdvSayi];

    prefs.setString('calisanTipi', calisanTipi);
  }

  Future<void> ayiYukle() async {
    debugPrint('Ay yükleniyor: ${seciliAy.month}/${seciliAy.year}');

    final sonGun = DateTime(seciliAy.year, seciliAy.month + 1, 0).day;
    List<CalismaGunModel> taslakGunler = List.generate(sonGun, (index) {
      return CalismaGunModel(
        tarih: DateTime(seciliAy.year, seciliAy.month, index + 1),
        calistiMi: false,
        mesaiVar: false,
      );
    });

    final kayitliGunler = appData.ayaGoreGetir(seciliAy.year, seciliAy.month);
    debugPrint('Kayıtlı gün sayısı: ${kayitliGunler.length}');

    for (var kayitli in kayitliGunler) {
      int index = kayitli.tarih.day - 1;
      if (index >= 0 && index < taslakGunler.length) {
        taslakGunler[index] = kayitli;
      }
    }

    gunlerNotifier.value = List<CalismaGunModel>.from(taslakGunler);

    if (mounted) {
      // GÜNLER YÜKLENDİKTEN SONRA BUGÜNE ORTALA
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          bugunuOrtala();
        }
      });

      widget.onKazancChanged?.call();
    }

    debugPrint('Ay yüklendi: ${taslakGunler.length} gün');
  }

  void ayDegistir(int fark) {
    debugPrint('Ay değiştiriliyor: $fark');
    setState(() => seciliAy = DateTime(seciliAy.year, seciliAy.month + fark));

    ayiYukle().then((_) {
      // YENİ AY YÜKLENDİKTEN SONRA BUGÜNE ORTALA
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          bugunuOrtala();
        }
      });
    });
  }

  void bugunuOrtala() {
    // 1. CONTROLLER KONTROLÜ
    if (!pageController.hasClients) {
      debugPrint('PageController clients yok');
      Future.delayed(const Duration(milliseconds: 500), () => bugunuOrtala());
      return;
    }

    // 2. VERİ KONTROLÜ
    if (gunlerNotifier.value.isEmpty) {
      debugPrint('Günler listesi boş');
      return;
    }

    // 3. TARİH KONTROLÜ
    final today = DateTime.now();
    final isCurrentMonth =
        seciliAy.month == today.month && seciliAy.year == today.year;

    if (!isCurrentMonth) {
      debugPrint('Geçerli ay değil, ortalamaya gerek yok');
      return;
    }

    // 4. BUGÜNÜ BUL
    int todayIndex = -1;
    for (int i = 0; i < gunlerNotifier.value.length; i++) {
      final gun = gunlerNotifier.value[i];
      if (gun.tarih.day == today.day &&
          gun.tarih.month == today.month &&
          gun.tarih.year == today.year) {
        todayIndex = i;
        break;
      }
    }

    // 5. BUGÜN BULUNAMADIYSA ORTAYA AL
    if (todayIndex == -1) {
      todayIndex = gunlerNotifier.value.length ~/ 2;
      debugPrint('Bugün bulunamadı, ortaya alınıyor: $todayIndex');
    } else {
      debugPrint('Bugün indexi: $todayIndex');
    }

    // 6. ANIMASYON YAP
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && pageController.hasClients) {
        pageController.animateToPage(
          todayIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        debugPrint('Bugüne ortalandı: $todayIndex');
      }
    });
  }

  // GENİŞLETİLMİŞ GÜN DİALOG'U
  void showGenisletilmisGunDialog(CalismaGunModel gun) async {
    debugPrint(
      'Gün dialog açılıyor: ${DateFormat('dd-MM-yyyy').format(gun.tarih)}',
    );

    await AcilanPencere.show(
      context: context,
      title: DateFormat('EEEE dd MMMM yyyy', 'tr_TR').format(gun.tarih),
      height: 0.9,
      content: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                _buildIslemGrubu(
                  title: 'ÇALIŞMA İŞLEMLERİ',
                  icon: Icons.work_outline,
                  color: Renk.pastelKoyuMavi,
                  children: _buildCalismaIslemleri(gun),
                ),
                const SizedBox(height: 20),

                // MESAI İŞLEMLERİ
                _buildIslemGrubu(
                  title: 'MESAI İŞLEMLERİ',
                  icon: Icons.access_time,
                  color: Renk.pastelKoyuMavi,
                  children: _buildMesaiIslemleri(gun),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIslemGrubu({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(children: children),
        ),
      ],
    );
  }

  List<Widget> _buildCalismaIslemleri(CalismaGunModel gun) {
    bool calismaVar = gun.calistiMi && gun.calismaSaati > 0;

    return [
      if (calismaVar) ...[
        _buildIslemTile(
          title: 'Çalışma Düzenle',
          subtitle:
              selectedIndex.value == 0
                  ? '${gun.calismaSaati.toStringAsFixed(1)} saat çalışmayı düzenle'
                  : '${gun.calismaSaati.toStringAsFixed(1)} gün çalışmayı düzenle',
          icon: Icons.edit,
          iconColor: Renk.pastelKoyuMavi,
          onTap: () async {
            Navigator.pop(context);
            await duzenleCalismaDialog(gun);
          },
        ),
        _buildIslemTile(
          title: 'Çalışma Sil',
          subtitle: 'Bu günün çalışma kaydını sil',
          icon: Icons.delete_outline,
          iconColor: Renk.kirmizi,
          onTap: () async {
            Navigator.pop(context);
            await silCalismaDialog(gun);
          },
        ),
      ] else ...[
        _buildIslemTile(
          title: 'Çalışma Ekle',
          subtitle: 'Bu güne çalışma kaydı ekle',
          icon: Icons.add_circle_outline,
          iconColor: Renk.pastelAcikMavi,
          onTap: () async {
            Navigator.pop(context);
            await calismaEkleDialog(gun);
          },
        ),
      ],
    ];
  }

  List<Widget> _buildMesaiIslemleri(CalismaGunModel gun) {
    bool mesaiVar = gun.mesaiVar && gun.mesaiSaati != 0;

    return [
      if (mesaiVar) ...[
        _buildIslemTile(
          title: 'Mesai Düzenle',
          subtitle:
              selectedIndex.value == 0
                  ? '${gun.mesaiSaati.toStringAsFixed(1)} saat mesaiyi düzenle'
                  : '${gun.mesaiSaati.toStringAsFixed(1)} gün mesaiyi düzenle',
          icon: Icons.edit,
          iconColor: Renk.pastelKoyuMavi,
          onTap: () async {
            Navigator.pop(context);
            await duzenleMesaiDialog(gun);
          },
        ),
        _buildIslemTile(
          title: 'Mesai Sil',
          subtitle: 'Bu günün mesai kaydını sil',
          icon: Icons.delete_outline,
          iconColor: Renk.kirmizi,
          onTap: () async {
            Navigator.pop(context);
            await silMesaiDialog(gun);
          },
        ),
      ],
      _buildIslemTile(
        title: 'Mesai Ekle',
        subtitle: 'Bu güne normal mesai ekle',
        icon: Icons.add_circle_outline,
        iconColor: Renk.pastelAcikMavi,
        onTap: () async {
          Navigator.pop(context);
          await mesaiEkleDialog(gun, isEksik: false);
        },
      ),
      _buildIslemTile(
        title: 'Eksik Saat/Mesai Ekle',
        subtitle: 'Eksik saat veya negatif mesai ekle',
        icon: Icons.remove_circle_outline,
        iconColor: Renk.kirmizi,
        onTap: () async {
          Navigator.pop(context);
          await mesaiEkleDialog(gun, isEksik: true);
        },
      ),
    ];
  }

  Widget _buildIslemTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: CizgiliCerceve(
        golge: 5,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 2,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> calismaEkleDialog(CalismaGunModel gun) async {
    final gunTarihStr = DateFormat('dd-MM-yyyy').format(gun.tarih);
    calismaHesaplama.tarihController.text = gunTarihStr;
    calismaHesaplama.tarihCalisma = gunTarihStr;
    await calismaHesaplama.calismaEkleDialog(
      context,
      onUpdate: () async {
        await uyarilariKaydet();
        await _guncelleTakvimVerileri();
        if (mounted) {
          FocusScope.of(context).unfocus();
          await Future.delayed(Duration(milliseconds: 100));
          // ignore: use_build_context_synchronously
          FocusScope.of(context).requestFocus(FocusNode());
        }
      },
      kdvOrani: _kdvOrani,
      calisanTipi: _calisanTipi,
      besAktif: _besAktif,
      besOrani: _besOrani,
    );
  }

  Future<void> duzenleCalismaDialog(CalismaGunModel gun) async {
    final gunTarihStr = DateFormat('dd-MM-yyyy').format(gun.tarih);
    final index = calismaHesaplama.calismaGunleri.indexWhere(
      (g) => DateFormat('dd-MM-yyyy').format(g.tarih) == gunTarihStr,
    );

    if (index != -1) {
      await calismaHesaplama.duzenleCalismaDialog(
        context,
        index,
        onUpdate: () async {
          await uyarilariKaydet();
          await _guncelleTakvimVerileri();
        },
        kdvOrani: _kdvOrani,
        calisanTipi: _calisanTipi,
        besAktif: _besAktif,
        besOrani: _besOrani,
      );
    }
  }

  Future<void> silCalismaDialog(CalismaGunModel gun) async {
    final confirm = await BilgiDialog.showConfirmationDialog(
      context: context,
      title: 'Çalışma Bilgisini Sil?',
      content: 'Bu günün çalışma bilgisini silmek istiyor musunuz?',
      yesText: 'Evet, Sil',
      noText: 'Hayır',
    );

    if (confirm == true) {
      final gunStr = DateFormat('dd-MM-yyyy').format(gun.tarih);
      final index = calismaHesaplama.calismaGunleri.indexWhere(
        (g) => DateFormat('dd-MM-yyyy').format(g.tarih) == gunStr,
      );
      if (index != -1) {
        await calismaHesaplama.listeyiGuncelle(
          islem: "sil",
          index: index,
          kdvOrani: _kdvOrani,
          calisanTipi: _calisanTipi,
          besAktif: _besAktif,
          besOrani: _besOrani,
        );

        await uyarilariKaydet();
        await _guncelleTakvimVerileri();

        // ignore: use_build_context_synchronously
        Mesaj.altmesaj(context, "Çalışma silindi", Colors.green);
      }
    }
  }

  Future<void> mesaiEkleDialog(
    CalismaGunModel gun, {
    required bool isEksik,
  }) async {
    final gunTarihStr = DateFormat('dd-MM-yyyy').format(gun.tarih);
    mesaiHesaplama.tarihController.text = gunTarihStr;
    mesaiHesaplama.tarihMesai = gunTarihStr;
    await mesaiHesaplama.mesaiEkleDialog(
      context,
      onUpdate: () async {
        await uyarilariKaydet();
        await _guncelleTakvimVerileri();
      },
      isEksik: isEksik,
    );
  }

  Future<void> duzenleMesaiDialog(CalismaGunModel gun) async {
    final gunTarihStr = DateFormat('dd-MM-yyyy').format(gun.tarih);
    final mesaiTarihleri = getMesaiTarihListe();
    final index = mesaiTarihleri.indexOf(gunTarihStr);
    if (index != -1) {
      await mesaiHesaplama.duzenleMesaiDialog(
        context,
        index,
        onUpdate: () async {
          await uyarilariKaydet();
          await _guncelleTakvimVerileri();
        },
      );
    }
  }

  Future<void> silMesaiDialog(CalismaGunModel gun) async {
    final gunTarihStr = DateFormat('dd-MM-yyyy').format(gun.tarih);
    final mesaiTarihleri = mesaiHesaplama.getMesaiTarihListe();
    final index = mesaiTarihleri.indexOf(gunTarihStr);
    if (index == -1) {
      // ignore: use_build_context_synchronously
      Mesaj.altmesaj(context, "❌ Mesai kaydı bulunamadı", Colors.red);
      return;
    }

    final confirm = await BilgiDialog.showConfirmationDialog(
      context: context,
      title: 'Mesai Bilgisini Sil?',
      content:
          '${DateFormat('dd-MM-yyyy').format(gun.tarih)} tarihli '
          'mesai bilgisini silmek istiyor musunuz?',
      yesText: 'Evet, Sil',
      noText: 'Hayır',
    );
    if (confirm == true) {
      mesaiHesaplama.listeyiGuncelle(islem: "sil", index: index);
      await uyarilariKaydet();
      await _guncelleTakvimVerileri();
      // ignore: use_build_context_synchronously
      Mesaj.altmesaj(context, "✅ Mesai silindi", Colors.green);
    }
  }

  List<String> getMesaiTarihListe() {
    final List<String> tarihler = [];
    for (final metin in mesaiHesaplama.mesaiMetinListe.value) {
      final parts = metin.split(' ');
      if (parts.length > 1) tarihler.add(parts[1]);
    }
    return tarihler;
  }

  Widget buildInfoIcon(
    BuildContext context,
    String yazi, {
    double iconSize = 18,
  }) {
    return GestureDetector(
      onTap: () {
        BilgiDialog.showCustomDialog(
          context: context,
          title: 'Notlar',
          content: yazi,
          buttonText: 'Kapat',
        );
      },
      child: Icon(
        Icons.info_outline,
        size: iconSize,
        color: Renk.pastelKoyuMavi,
      ),
    );
  }

  List<CalismaGunModel?> _haftalaraGoreDuzenle(
    List<CalismaGunModel> gunlerList,
  ) {
    final result = <CalismaGunModel?>[];
    final firstDayOfMonth = DateTime(seciliAy.year, seciliAy.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final emptyCells = firstWeekday - 1;
    for (int i = 0; i < emptyCells; i++) {
      result.add(null);
    }
    result.addAll(gunlerList);
    final totalWeeks = ((result.length) / 7).ceil();
    final totalCells = totalWeeks * 7;
    while (result.length < totalCells) {
      result.add(null);
    }
    return result;
  }

  Widget _buildTakvimGridView(List<CalismaGunModel> gunlerList) {
    final haftalikListe = _haftalaraGoreDuzenle(gunlerList);
    final haftaSayisi = (haftalikListe.length / 7).ceil();
    final double hucreYuksekligi = 68;
    final double toplamYukseklik =
        (hucreYuksekligi * haftaSayisi) + ((haftaSayisi - 1) * 6) + 20;
    return Container(
      height: toplamYukseklik,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.75,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
        ),
        itemCount: haftalikListe.length,
        itemBuilder: (context, index) {
          final item = haftalikListe[index];
          if (item == null) return Container();
          final gun = item;
          Color kartRengi = Renk.pastelKirmizi; // varsayılan

          if (gun.calistiMi && gun.mesaiVar) {
            kartRengi = Renk.pastelMavi;
          } else if (gun.calistiMi) {
            kartRengi = Renk.pastelYesil;
          } else if (gun.mesaiVar) {
            kartRengi =
                gun.mesaiSaati >= 0
                    ? Renk.pastelMavi
                    : Colors.red.shade50; // eksikse açık kırmızı ton
          }
          String notlar = '';
          if (gun.calismaNotu != null && gun.calismaNotu!.isNotEmpty) {
            notlar += 'Ç: ${gun.calismaNotu!}';
          }
          if (gun.mesaiNotu != null && gun.mesaiNotu!.isNotEmpty) {
            notlar +=
                notlar.isNotEmpty
                    ? '\nM: ${gun.mesaiNotu!}'
                    : 'M: ${gun.mesaiNotu!}';
          }
          return GestureDetector(
            onTap: () => showGenisletilmisGunDialog(gun),
            child: Card(
              color: kartRengi,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${gun.tarih.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                (gun.calistiMi || gun.mesaiVar)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: Colors.black54,
                          ),
                        ),
                        if (notlar.isNotEmpty)
                          buildInfoIcon(context, notlar, iconSize: 13),
                      ],
                    ),
                    if (gun.calistiMi && gun.calismaSaati > 0)
                      Row(
                        children: [
                          const Text(
                            'Ç',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            gun.calismaSaati.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    if (gun.mesaiVar)
                      Row(
                        children: [
                          Text(
                            'M',
                            style: TextStyle(
                              fontSize: 8,
                              color:
                                  gun.mesaiSaati > 0
                                      ? Colors.green
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            gun.mesaiSaati.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 8,
                              color:
                                  gun.mesaiSaati > 0
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget detayGunCard(CalismaGunModel gun) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, currentIndex, _) {
        final birim = currentIndex == 0 ? "saat" : "gün";
        Color kartRengi = Renk.pastelKirmizi; // varsayılan

        if (gun.calistiMi && gun.mesaiVar) {
          kartRengi = Renk.pastelMavi;
        } else if (gun.calistiMi) {
          kartRengi = Renk.pastelYesil;
        } else if (gun.mesaiVar) {
          kartRengi =
              gun.mesaiSaati >= 0
                  ? Renk.pastelMavi
                  : Colors.red.shade50; // eksikse açık kırmızı ton
        }
        // NOTLAR
        String notlar = '';
        if (gun.calismaNotu != null && gun.calismaNotu!.isNotEmpty) {
          notlar += 'Çalışma Notu: ${gun.calismaNotu!}\n';
        }
        if (gun.mesaiNotu != null && gun.mesaiNotu!.isNotEmpty) {
          notlar += 'Mesai Notu: ${gun.mesaiNotu!}';
        }
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: kartRengi,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TARİH
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${gun.tarih.day}',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEEE', 'tr_TR').format(gun.tarih),
                          style: const TextStyle(fontSize: 15),
                        ),
                        if (notlar.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: buildInfoIcon(context, notlar, iconSize: 16),
                          ),
                      ],
                    ),
                  ],
                ),

                Dekor.cizgi15,

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (gun.calistiMi) ...[
                        if (gun.calismaSaati > 0)
                          Column(
                            children: [
                              const Text(
                                'Çalışma Bilgisi',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${gun.calismaSaati.toStringAsFixed(1)} $birim',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Renk.pastelKoyuMavi,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),

                        if (gun.calismaNet > 0)
                          Text(
                            '${gun.calismaNet.toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Renk.pastelKoyuMavi,
                            ),
                          ),
                        const SizedBox(height: 2),
                      ],

                      if (gun.mesaiVar) ...[
                        Column(
                          children: [
                            const Text(
                              'Mesai Bilgisi',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${gun.mesaiSaati.toStringAsFixed(1)} saat',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Renk.pastelKoyuMavi,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),

                        if (gun.mesaiNet != 0)
                          Text(
                            '${gun.mesaiNet.toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Renk.pastelKoyuMavi,
                            ),
                          ),
                        const SizedBox(height: 2),
                      ],

                      if (gun.calistiMi || gun.mesaiVar)
                        Column(
                          children: [
                            Text(
                              gun.mesaiSaati < 0
                                  ? 'Toplam Kesinti'
                                  : 'Toplam Kazanç',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            ),
                            Text(
                              '${gun.toplamKazanc.toStringAsFixed(2)} ₺',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Renk.pastelKoyuMavi,
                              ),
                            ),
                          ],
                        )
                      else
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Çalışma/Mesai\nYok',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 35,
                    color: Renk.pastelKoyuMavi,
                  ),
                  onPressed: () => showGenisletilmisGunDialog(gun),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!veriYuklendi) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Takvim verileri yükleniyor...'),
          ],
        ),
      );
    }

    return ValueListenableBuilder<List<CalismaGunModel>>(
      valueListenable: gunlerNotifier,
      builder: (context, gunlerList, child) {
        return Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: selectedIndex,
              builder: (context, selectedIndexValue, _) {
                return MesaiSecenekler(
                  selectedIndex: selectedIndexValue,
                  onIndexChanged: (index) async {
                    selectedIndex.value = index;
                    calismaHesaplama.selectedIndex.value = index;
                    mesaiHesaplama.selectedIndex.value = index;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('index', index);

                    await uyarilariYukle();
                    await _guncelleTakvimVerileri();

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  onTipDegisti: () async {
                    calisanTipi =
                        calisanTipi == 'Normal'
                            ? 'Emekli'
                            : calisanTipi == 'Emekli'
                            ? 'SGK Yok'
                            : 'Normal';
                    await uyarilariKaydet();
                  },
                  calisanTipi: calisanTipi,
                  calismaHesaplama: calismaHesaplama,
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 30),
                      onPressed: () => ayDegistir(-1),
                    ),
                    Text(
                      DateFormat('        MMMM yyyy', 'tr_TR').format(seciliAy),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            gorunumModu ? Icons.view_carousel : Icons.grid_view,
                            size: 26,
                          ),
                          onPressed: () {
                            setState(() => gorunumModu = !gorunumModu);
                            if (gorunumModu) bugunuOrtala();
                            widget.onKazancChanged?.call();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 30),
                          onPressed: () => ayDegistir(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (gorunumModu)
              SizedBox(
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                    top: 10,
                    left: 4,
                    right: 4,
                  ),
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: gunlerList.length,
                    pageSnapping: false,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: detayGunCard(gunlerList[index]),
                      );
                    },
                  ),
                ),
              )
            else
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cts', 'Paz']
                              .map(
                                (gunAdi) => Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      gunAdi,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  _buildTakvimGridView(gunlerList),
                ],
              ),
          ],
        );
      },
    );
  }
}
