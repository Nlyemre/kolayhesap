import 'dart:convert';
import 'dart:math';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YapilacaklarListesi extends StatefulWidget {
  final VoidCallback? onListeGuncellendi;

  const YapilacaklarListesi({super.key, this.onListeGuncellendi});

  @override
  State<YapilacaklarListesi> createState() => _YapilacaklarListesiState();
}

class _YapilacaklarListesiState extends State<YapilacaklarListesi> {
  List<Map<String, dynamic>> yapilacaklarListesi = [];
  int _secilenIndex = -1;
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _tarihController = TextEditingController();
  static const platform = MethodChannel('notification_settings');
  final _dateFormat = DateFormat('dd-MM-yyyy HH:mm', 'tr_TR');
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
    _listeyiYukle();
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    _tarihController.dispose();
    super.dispose();
  }

  Future<bool> _isValidNotificationTime(String tarihStr) async {
    final tarih = _dateFormat.parse(tarihStr);
    return tarih.isAfter(DateTime.now());
  }

  Future<void> _scheduleNotification(Map<String, dynamic> task) async {
    try {
      if (!await _isValidNotificationTime(task['tarih'])) {
        throw PlatformException(
          code: 'INVALID_TIME',
          message: 'Geçmiş tarihli bildirim planlanamaz',
        );
      }

      final tarih = _dateFormat.parse(task['tarih']);
      final taskId = '${task['baslik']}_${_random.nextInt(100000)}';

      task['taskId'] = taskId;

      await platform.invokeMethod('scheduleTaskNotification', {
        'taskId': taskId,
        'title': task['baslik'],
        'body': task['aciklama'] ?? '',
        'timestamp': tarih.millisecondsSinceEpoch,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      });
    } on PlatformException catch (e) {
      // ignore: use_build_context_synchronously
      Mesaj.altmesaj(context, 'Bildirim hatası: ${e.message}', Colors.red);
    }
  }

  Future<bool> _checkAndRequestNotificationPermission() async {
    try {
      // Önce mevcut izni kontrol et
      bool hasPermission = await _checkNotificationPermission();

      if (!hasPermission) {
        // İzin yoksa ayarları aç
        await platform.invokeMethod('openAlarmPermissionSettings');
      }
      return hasPermission;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _cancelNotification(String taskId) async {
    await platform.invokeMethod('cancelTaskNotification', {'taskId': taskId});
  }

  Future<void> _listeyiYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final String? listeJson = prefs.getString('yapilacaklarListesi');

    if (listeJson != null) {
      if (!mounted) return;

      setState(() {
        yapilacaklarListesi = List<Map<String, dynamic>>.from(
          json.decode(listeJson).map((x) => Map<String, dynamic>.from(x)),
        );

        yapilacaklarListesi.sort(
          (a, b) => _dateFormat
              .parse(a['tarih'])
              .compareTo(_dateFormat.parse(b['tarih'])),
        );
      });
    }
  }

  Future<void> _listeyiKaydet() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'yapilacaklarListesi',
      json.encode(yapilacaklarListesi),
    );

    if (widget.onListeGuncellendi != null && mounted) {
      widget.onListeGuncellendi!();
    }
  }

  // Bildirim izni kontrol fonksiyonu
  Future<bool> _checkNotificationPermission() async {
    try {
      final bool? permissionCheck = await platform.invokeMethod<bool>(
        'checkAlarmPermission',
      );
      return permissionCheck ?? false;
    } on PlatformException {
      return false;
    }
  }

  void _goreviBildirimleSil(int index) async {
    final taskId = yapilacaklarListesi[index]['taskId'];
    if (taskId != null) {
      await _cancelNotification(taskId);
    }

    setState(() {
      yapilacaklarListesi.removeAt(index);
      _listeyiKaydet();
    });
  }

  String _kalanSureyiHesapla(DateTime hedefTarih) {
    final simdi = DateTime.now();
    final fark = hedefTarih.difference(simdi);

    if (fark.isNegative) {
      return 'Süre doldu';
    } else if (fark.inDays > 0) {
      return '${fark.inDays} gün ${fark.inHours % 24} saat kaldı';
    } else if (fark.inHours > 0) {
      return '${fark.inHours} saat ${fark.inMinutes % 60} dakika kaldı';
    } else if (fark.inMinutes > 0) {
      return '${fark.inMinutes} dakika kaldı';
    } else {
      return '${fark.inSeconds} saniye kaldı';
    }
  }

  Widget _bildirimiznisorgu() {
    return Column(
      children: [
        const Text(
          "Alarm İzni Gerekli",
          style: TextStyle(
            color: Renk.koyuMavi,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Görevlerinizi ve hatırlatmalarınızı zamanında takip edebilmeniz için, uygulamamızın bildirim gönderme iznine ihtiyacı vardır. Bu izin sayesinde, cihazınıza gelen önemli hatırlatmaları kaçırmadan takip edebilir ve planlarınıza uygun şekilde hareket edebilirsiniz. Bildirim iznini etkinleştirerek, zaman yönetiminizi kolaylaştırabilir ve işlerinizi daha verimli hale getirebilirsiniz.",
          textAlign: TextAlign.center,
        ),
        Dekor.cizgi15,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const SizedBox(height: 5),
              const Icon(
                Icons.notifications_off,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Bildirim gönderilemeyecek",
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
              const Spacer(),
              Container(
                height: 35,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Renk.cita,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
                child: TextButton(
                  child: const Text(
                    "Ayarlara Git",
                    style: TextStyle(
                      color: Renk.koyuMavi,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onPressed: () async {
                    await _checkAndRequestNotificationPermission();
                    kapat();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void kapat() {
    Navigator.of(context).pop();
  }

  void _yeniGorevEkleDialog() {
    _tarihController.text = DateFormat(
      'dd-MM-yyyy HH:mm',
    ).format(DateTime.now());
    bool hasNotificationPermission = false;
    bool isPermissionChecked = false;

    AcilanPencere.show(
      context: context,
      title: 'Yeni Görev Ekle',
      height: 0.9,
      showAd: false,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          // İzin durumunu kontrol et ve güncelle
          Future<void> checkAndUpdatePermission() async {
            final value = await _checkNotificationPermission();
            if (mounted) {
              setModalState(() {
                hasNotificationPermission = value;
              });
            }
          }

          if (!isPermissionChecked) {
            isPermissionChecked = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              checkAndUpdatePermission();
            });
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _baslikController,
                          decoration: const InputDecoration(
                            labelText: 'Başlık',
                            hintText: 'Görev başlığını yazın',
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _aciklamaController,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            hintText: 'Görev detaylarını yazın',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? secilenTarih = await showDatePicker(
                              context: context,
                              initialDate:
                                  _tarihController.text.isNotEmpty
                                      ? DateFormat(
                                        'dd-MM-yyyy HH:mm',
                                      ).parse(_tarihController.text)
                                      : DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (!mounted) return;
                            if (secilenTarih == null) return;

                            final TimeOfDay? secilenSaat = await showTimePicker(
                              // ignore: use_build_context_synchronously
                              context: context,
                              initialTime:
                                  _tarihController.text.isNotEmpty
                                      ? TimeOfDay.fromDateTime(
                                        DateFormat(
                                          'dd-MM-yyyy HH:mm',
                                        ).parse(_tarihController.text),
                                      )
                                      : TimeOfDay.now(),
                            );

                            if (secilenSaat != null && mounted) {
                              final DateTime birlesikTarih = DateTime(
                                secilenTarih.year,
                                secilenTarih.month,
                                secilenTarih.day,
                                secilenSaat.hour,
                                secilenSaat.minute,
                              );

                              setModalState(() {
                                _tarihController.text = DateFormat(
                                  'dd-MM-yyyy HH:mm',
                                ).format(birlesikTarih);
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _tarihController,
                              decoration: const InputDecoration(
                                labelText: 'Tarih ve Saat',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        hasNotificationPermission
                            ? const RepaintBoundary(child: YerelReklamiki())
                            : _bildirimiznisorgu(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 25,
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _temizleControllers();
                          kapat();
                        },
                        child: Renk.buton("İptal", 45),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (_baslikController.text.isEmpty ||
                              _aciklamaController.text.isEmpty) {
                            Mesaj.altmesaj(
                              context,
                              'Lütfen başlık ve açıklama giriniz.',
                              Colors.red,
                            );
                            return;
                          }

                          try {
                            final hasPermission =
                                await _checkNotificationPermission();
                            final taskId =
                                'task_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
                            final yeniGorev = {
                              'baslik': _baslikController.text,
                              'aciklama': _aciklamaController.text,
                              'tarih': _tarihController.text,
                              'taskId': taskId,
                            };

                            if (mounted) {
                              setState(() {
                                yapilacaklarListesi.add(yeniGorev);
                                yapilacaklarListesi.sort(
                                  (a, b) => _dateFormat
                                      .parse(a['tarih'])
                                      .compareTo(_dateFormat.parse(b['tarih'])),
                                );
                              });
                            }

                            if (hasPermission) {
                              await _scheduleNotification(yeniGorev);
                            }
                            await _listeyiKaydet();
                            _temizleControllers();
                            kapat();
                          } catch (e) {
                            if (mounted) {
                              Mesaj.altmesaj(
                                // ignore: use_build_context_synchronously
                                context,
                                'Görev eklenirken hata oluştu',
                                Colors.red,
                              );
                            }
                          }
                        },
                        child: Renk.buton("Kaydet", 45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ).then((_) => _temizleControllers());
  }

  void _temizleControllers() {
    if (_baslikController.text.isNotEmpty) _baslikController.clear();
    if (_aciklamaController.text.isNotEmpty) _aciklamaController.clear();
    if (_tarihController.text.isNotEmpty) _tarihController.clear();
  }

  void _gorevDuzenleDialog(int index) {
    _baslikController.text = yapilacaklarListesi[index]['baslik'];
    _aciklamaController.text = yapilacaklarListesi[index]['aciklama'];
    _tarihController.text = yapilacaklarListesi[index]['tarih'];
    bool hasNotificationPermission = false;
    bool isPermissionChecked = false;

    AcilanPencere.show(
      context: context,
      title: 'Görevi Düzenle',
      height: 0.9,
      showAd: false,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          // İzin durumunu kontrol et ve güncelle
          Future<void> checkAndUpdatePermission() async {
            final value = await _checkNotificationPermission();
            if (mounted) {
              setModalState(() {
                hasNotificationPermission = value;
              });
            }
          }

          if (!isPermissionChecked) {
            isPermissionChecked = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              checkAndUpdatePermission();
            });
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _baslikController,
                          decoration: const InputDecoration(
                            labelText: 'Başlık',
                            hintText: 'Görev başlığını yazın',
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _aciklamaController,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            hintText: 'Görev detaylarını yazın',
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? secilenTarih = await showDatePicker(
                              context: context,
                              initialDate:
                                  _tarihController.text.isNotEmpty
                                      ? DateFormat(
                                        'dd-MM-yyyy HH:mm',
                                      ).parse(_tarihController.text)
                                      : DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (!mounted) return;
                            if (secilenTarih == null) return;

                            final TimeOfDay? secilenSaat = await showTimePicker(
                              // ignore: use_build_context_synchronously
                              context: context,
                              initialTime:
                                  _tarihController.text.isNotEmpty
                                      ? TimeOfDay.fromDateTime(
                                        DateFormat(
                                          'dd-MM-yyyy HH:mm',
                                        ).parse(_tarihController.text),
                                      )
                                      : TimeOfDay.now(),
                            );

                            if (secilenSaat != null && mounted) {
                              final DateTime birlesikTarih = DateTime(
                                secilenTarih.year,
                                secilenTarih.month,
                                secilenTarih.day,
                                secilenSaat.hour,
                                secilenSaat.minute,
                              );

                              setModalState(() {
                                _tarihController.text = DateFormat(
                                  'dd-MM-yyyy HH:mm',
                                ).format(birlesikTarih);
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _tarihController,
                              decoration: const InputDecoration(
                                labelText: 'Tarih ve Saat',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        hasNotificationPermission
                            ? const RepaintBoundary(child: YerelReklamuc())
                            : _bildirimiznisorgu(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 25,
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _temizleControllers();
                          kapat();
                        },
                        child: Renk.buton("İptal", 45),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (_baslikController.text.isEmpty ||
                              _aciklamaController.text.isEmpty) {
                            Mesaj.altmesaj(
                              context,
                              'Lütfen başlık ve açıklama giriniz.',
                              Colors.red,
                            );
                            return;
                          }

                          try {
                            final hasPermission =
                                await _checkNotificationPermission();
                            final taskId =
                                yapilacaklarListesi[index]['taskId'] ??
                                'task_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
                            final guncellenmisGorev = {
                              'baslik': _baslikController.text,
                              'aciklama': _aciklamaController.text,
                              'tarih': _tarihController.text,
                              'taskId': taskId,
                            };

                            final eskiTaskId =
                                yapilacaklarListesi[index]['taskId'];
                            if (eskiTaskId != null) {
                              await _cancelNotification(eskiTaskId);
                            }

                            if (mounted) {
                              setState(() {
                                yapilacaklarListesi[index] = guncellenmisGorev;
                                yapilacaklarListesi.sort(
                                  (a, b) => _dateFormat
                                      .parse(a['tarih'])
                                      .compareTo(_dateFormat.parse(b['tarih'])),
                                );
                              });
                            }

                            if (hasPermission) {
                              await _scheduleNotification(guncellenmisGorev);
                            }
                            await _listeyiKaydet();
                            _temizleControllers();
                            kapat();
                          } catch (e) {
                            if (mounted) {
                              Mesaj.altmesaj(
                                // ignore: use_build_context_synchronously
                                context,
                                'Görev güncellenirken hata oluştu',
                                Colors.red,
                              );
                            }
                          }
                        },
                        child: Renk.buton("Kaydet", 45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ).then((_) => _temizleControllers());
  }

  Color _kalanSureRenginiBelirle(DateTime hedefTarih) {
    final simdi = DateTime.now();
    final fark = hedefTarih.difference(simdi);

    if (fark.isNegative) {
      return Colors.red;
    } else {
      return Renk.koyuMavi;
    }
  }

  String onboardingText = """
 Görevlerinizi ve hatırlatmalarınızı kolayca yönetebileceğiniz kişisel asistanınız artık burada.

🔔 Bildirim özellikleri:

• Önemli görevlerinizi zamanında hatırlatma
• Planlarınızdan haberdar olma imkanı
• Unutma stresi yaşamadan çalışma

✨ Nasıl çalışır?

1️⃣ Görevlerinizi ekleyin
2️⃣ Hatırlatma zamanını belirleyin
3️⃣ Tam vaktinde uyarı alın

"Zaman yönetiminizin sırrı burada başlıyor! Hadi başlayalım."
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.koyuMavi),

        title: const Text("Yapılacaklar Listesi"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              yapilacaklarListesi.isEmpty
                  ? Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: RepaintBoundary(child: YerelReklamuc()),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                            ),
                            child: Text(
                              onboardingText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: Image.asset('assets/images/r538.png'),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: yapilacaklarListesi.length,
                      separatorBuilder: (context, index) {
                        if (yapilacaklarListesi.length > 2 && index == 1) {
                          return const Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 8,
                            ),
                            child: RepaintBoundary(child: YerelReklam()),
                          );
                        }
                        return const SizedBox(height: 1);
                      },
                      itemBuilder: (context, index) {
                        final gorev = yapilacaklarListesi[index];
                        final tarihFormat = DateFormat('dd-MM-yyyy HH:mm');
                        final tarih = tarihFormat.parse(gorev['tarih']);
                        final formatliTarih = DateFormat(
                          'dd MMMM yyyy HH:mm',
                          'tr_TR',
                        ).format(tarih);
                        final kalanSure = _kalanSureyiHesapla(tarih);
                        bool seciliMi = _secilenIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_secilenIndex == index) {
                                _secilenIndex = -1;
                              } else {
                                _secilenIndex = index;
                              }
                            });
                          },
                          child: Stack(
                            children: [
                              if (seciliMi)
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _gorevDuzenleDialog(index);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 7,
                                              right: 7,
                                              top: 5,
                                              bottom: 5,
                                            ),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: Renk.gradient,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0),
                                                ),
                                              ),
                                              width: 60,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _goreviBildirimleSil(index);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 5,
                                              top: 5,
                                              right: 10,
                                            ),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red,
                                                    Colors.red,
                                                  ],
                                                  begin: Alignment(1.0, -1.0),
                                                  end: Alignment(1.0, 1.0),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0),
                                                ),
                                              ),
                                              width: 60,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                transform: Matrix4.translationValues(
                                  seciliMi ? -135 : 0,
                                  0,
                                  0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  child: CizgiliCerceve(
                                    golge: 5,
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 5,
                                        ),
                                        child: Text(
                                          gorev['baslik'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(gorev['aciklama']),
                                          Dekor.cizgi15,
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                formatliTarih,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                kalanSure,
                                                style: TextStyle(
                                                  color:
                                                      _kalanSureRenginiBelirle(
                                                        tarih,
                                                      ),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              const RepaintBoundary(child: BannerReklamuc()),
            ],
          ),
          Positioned(
            right: 14,
            bottom: 90,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _yeniGorevEkleDialog,
                backgroundColor: Colors.white,
                elevation: 5,
                child: const Icon(Icons.add, size: 30, color: Renk.koyuMavi),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
