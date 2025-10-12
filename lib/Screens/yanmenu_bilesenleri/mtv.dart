import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/yanmenu_bilesenleri/mtv_son.dart';
import 'package:flutter/material.dart';

class MTVhesapla extends StatefulWidget {
  const MTVhesapla({super.key});

  @override
  State<MTVhesapla> createState() => _MTVhesaplaState();
}

class _MTVhesaplaState extends State<MTVhesapla> {
  String _aractipi = "Lütfen Seçiniz";
  int yas = 0;
  int motorHacmi = 0;
  int _mtv = 0;
  int tasitDegeri = 0;
  String _tesciltarihi = 'Lütfen Seçiniz';
  String _elektrikli = "Hayır";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.koyuMavi),

        title: const Text("Araç MTV Hesapla"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _buildDropdown(
                      label: 'Araç Tipi',
                      value: _aractipi,
                      items: const [
                        'Lütfen Seçiniz',
                        'Otomobil',
                        'Motosiklet',
                        'Minibüs',
                        'Panelvan',
                        'Otobüs',
                        'Kamyonet',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _aractipi = value!;
                          motorHacmi = 0;
                          _tesciltarihi = 'Lütfen Seçiniz';
                          yas = 0;
                        });
                      },
                    ),
                    _buildDropdown(
                      label: 'Araç % 100 Elektrikli mi?',
                      value: _elektrikli,
                      items: const ['Evet', 'Hayır'],
                      onChanged: (value) {
                        setState(() {
                          _elektrikli = value!;
                          motorHacmi = 0;
                        });
                      },
                    ),
                    if (_aractipi == 'Otomobil')
                      _buildDropdown(
                        label: 'Tescil Tarihini Seçin',
                        value: _tesciltarihi,
                        items: const ['Lütfen Seçiniz', 'Öncesi', 'Sonrası'],
                        onChanged: (value) {
                          setState(() {
                            _tesciltarihi = value!;
                            motorHacmi = 0;
                          });
                        },
                      ),
                    _buildAracYasDropdown(),
                    _buildMotorHacmiDropdown(),
                    if (_tesciltarihi == 'Sonrası') _buildTasitDegeriDropdown(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          _validateAndCalculate();
                        },
                        child: Renk.buton("Hesapla", 50),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: RepaintBoundary(child: YerelReklam()),
                    ),
                    _buildInfoSection(),
                  ],
                ),
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklamiki()),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, top: 7),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        dropdownColor:
            Colors.white, // Açılan panelin arkaplan rengini beyaz yapar
        initialValue: value,
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: Dekor.butonText_14_500siyah),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAracYasDropdown() {
    List<DropdownMenuItem<int>> yasItems;
    if (_aractipi == 'Otomobil' || _aractipi == 'Motosiklet') {
      yasItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 3,
          child: Text('1 - 3 yaş', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 6,
          child: Text('4 - 6 yaş', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 11,
          child: Text('7 - 11 yaş', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 15,
          child: Text('12 - 15 yaş', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 16,
          child: Text('16 ve üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else {
      yasItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 6,
          child: Text('1 - 6 yaş', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 15,
          child: Text('7 - 15 yaş', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 16,
          child: Text('16 ve üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 7, top: 7),
      child: DropdownButtonFormField<int>(
        initialValue: yas,
        decoration: const InputDecoration(labelText: 'Araç Yaşı'),
        dropdownColor:
            Colors.white, // Açılan panelin arkaplan rengini beyaz yapar
        items: yasItems,
        onChanged: (value) {
          setState(() {
            yas = value!;
          });
        },
      ),
    );
  }

  Widget _buildMotorHacmiDropdown() {
    List<DropdownMenuItem<int>> motorHacmiItems;
    if (_aractipi == 'Otomobil') {
      if (_elektrikli == "Hayır") {
        motorHacmiItems = const [
          DropdownMenuItem(
            value: 0,
            child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 1300,
            child: Text('1300 ve altı', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 1600,
            child: Text('1301 - 1600', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 1800,
            child: Text('1601 - 1800', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 2000,
            child: Text('1801 - 2000', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 2500,
            child: Text('2001 - 2500', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 3000,
            child: Text('2501 - 3000', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 3500,
            child: Text('3001 - 3500', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 4000,
            child: Text('3501 - 4000', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 4001,
            child: Text('4001 ve üzeri', style: Dekor.butonText_14_500siyah),
          ),
        ];
      } else {
        motorHacmiItems = const [
          DropdownMenuItem(
            value: 0,
            child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 70,
            child: Text('70 kW ve altı', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 85,
            child: Text('71 kW - 85 kW', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 105,
            child: Text('86 kW - 105 kW', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 120,
            child: Text('106 kW - 120 kW', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 150,
            child: Text('120 kW - 150 kW', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 180,
            child: Text('151 kW - 180 kW', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 210,
            child: Text('180 kW - 210 kW', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 240,
            child: Text('211 kW - 240 kW', style: Dekor.butonText_14_500siyah),
          ),
          DropdownMenuItem(
            value: 241,
            child: Text('241 kW ve üzeri', style: Dekor.butonText_14_500siyah),
          ),
        ];
      }
    } else if (_aractipi == 'Motosiklet') {
      motorHacmiItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 250,
          child: Text('100 - 250 cm³', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 650,
          child: Text('251 - 650 cm³', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1200,
          child: Text('651 - 1200 cm³', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1201,
          child: Text('1201 cm³ ve üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else {
      motorHacmiItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 7, top: 7),
      child: DropdownButtonFormField<int>(
        initialValue: motorHacmi,
        decoration: const InputDecoration(
          labelText: 'Motor Silindir Hacmi (cm³)',
        ),
        dropdownColor:
            Colors.white, // Açılan panelin arkaplan rengini beyaz yapar
        items: motorHacmiItems,
        onChanged: (value) {
          setState(() {
            motorHacmi = value!;
          });
        },
      ),
    );
  }

  Widget _buildTasitDegeriDropdown() {
    List<DropdownMenuItem<int>> tasitDegeriItems;

    if (motorHacmi <= 1300) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 259900,
          child: Text(
            '259.900 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 455300,
          child: Text(
            '259.900 TL ile 455.300 TL arası',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 455301,
          child: Text('455.301 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 1600) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 259900,
          child: Text(
            '259.900 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 455300,
          child: Text(
            '259.900 TL ile 455.300 TL arası',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 455301,
          child: Text('455.301 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 1800) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 651715,
          child: Text(
            '651.700 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 651701,
          child: Text('651.701 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 2000) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 651700,
          child: Text(
            '651.700 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 651701,
          child: Text('651.701 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 2500) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 813900,
          child: Text(
            '813.900 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 813901,
          child: Text('813.901 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 3000) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1628900,
          child: Text(
            '1.628.900 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 1628901,
          child: Text('1.628.901 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 3500) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1628900,
          child: Text(
            '1.628.900 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 1628901,
          child: Text('1.628.901 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 4000) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 2607700,
          child: Text(
            '2.607.700 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 2607701,
          child: Text('2.607.701 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 3096500,
          child: Text(
            '3.096.500 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 3096501,
          child: Text('3.096.501 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    }

    // Seçili değer listede var mı kontrol et, yoksa null ata
    int? selectedValue =
        tasitDegeriItems.any((item) => item.value == tasitDegeri)
            ? tasitDegeri
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7, top: 7),
      child: DropdownButtonFormField<int>(
        initialValue: selectedValue,
        decoration: const InputDecoration(labelText: 'Taşıt Değerini Seçin'),
        dropdownColor: Colors.white,
        items: tasitDegeriItems,
        onChanged: (value) {
          setState(() {
            tasitDegeri = value!;
          });
        },
      ),
    );
  }

  void _validateAndCalculate() {
    if (_aractipi == "Lütfen Seçiniz") {
      Mesaj.altmesaj(context, 'Lütfen Araç Tipi Seçiniz', Colors.red);
    } else if (_aractipi == "Otomobil" && _tesciltarihi == "Lütfen Seçiniz") {
      Mesaj.altmesaj(context, 'Lütfen Tescil Tarihi Seçiniz', Colors.red);
    } else if (yas == 0) {
      Mesaj.altmesaj(context, 'Lütfen Araç Yaşı Seçiniz', Colors.red);
    } else if (motorHacmi == 0) {
      Mesaj.altmesaj(context, 'Lütfen Motor Hacmi Seçiniz', Colors.red);
    } else if (_tesciltarihi == "Sonrası" && tasitDegeri == 0) {
      Mesaj.altmesaj(context, 'Lütfen Taşıt Değeri Seçiniz', Colors.red);
    } else {
      _calculateMTV(_aractipi, _elektrikli);
    }
  }

  void _calculateMTV(String arac, String elektrik) {
    if (arac == 'Otomobil') {
      if (elektrik == "Hayır") {
        if (motorHacmi <= 1300) {
          if (_tesciltarihi == 'Öncesi') {
            if (yas <= 3) {
              _mtv = 4834; // Öncesi, 0-3 yaş
            } else if (yas <= 6) {
              _mtv = 3372; // Öncesi, 4-6 yaş
            } else if (yas <= 11) {
              _mtv = 1882; // Öncesi, 7-11 yaş
            } else if (yas <= 15) {
              _mtv = 1420; // Öncesi, 12-15 yaş
            } else {
              _mtv = 499; // Öncesi, 16+ yaş
            }
          } else {
            if (tasitDegeri <= 259900) {
              _mtv =
                  (yas <= 3)
                      ? 4834
                      : (yas <= 6)
                      ? 3372
                      : (yas <= 11)
                      ? 1882
                      : (yas <= 15)
                      ? 1420
                      : 499;
            } else if (tasitDegeri <= 455300) {
              _mtv =
                  (yas <= 3)
                      ? 5313
                      : (yas <= 6)
                      ? 3707
                      : (yas <= 11)
                      ? 2068
                      : (yas <= 15)
                      ? 1565
                      : 551;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 5803
                      : (yas <= 6)
                      ? 4042
                      : (yas <= 11)
                      ? 2264
                      : (yas <= 15)
                      ? 1709
                      : 594;
            }
          }
        } else if (motorHacmi <= 1600) {
          if (_tesciltarihi == 'Öncesi') {
            _mtv =
                (yas <= 3)
                    ? 8421
                    : (yas <= 6)
                    ? 6314
                    : (yas <= 11)
                    ? 3661
                    : (yas <= 15)
                    ? 2587
                    : 993;
          } else {
            if (tasitDegeri <= 259900) {
              _mtv =
                  (yas <= 3)
                      ? 8421
                      : (yas <= 6)
                      ? 6314
                      : (yas <= 11)
                      ? 3661
                      : (yas <= 15)
                      ? 2587
                      : 993;
            } else if (tasitDegeri <= 455300) {
              _mtv =
                  (yas <= 3)
                      ? 9267
                      : (yas <= 6)
                      ? 6948
                      : (yas <= 11)
                      ? 4031
                      : (yas <= 15)
                      ? 2838
                      : 1085;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 10112
                      : (yas <= 6)
                      ? 7577
                      : (yas <= 11)
                      ? 4389
                      : (yas <= 15)
                      ? 3098
                      : 1184;
            }
          }
        } else if (motorHacmi <= 1800) {
          if (_tesciltarihi == 'Öncesi') {
            _mtv =
                (yas <= 3)
                    ? 14885
                    : (yas <= 6)
                    ? 11626
                    : (yas <= 11)
                    ? 6848
                    : (yas <= 15)
                    ? 4168
                    : 1612;
          } else {
            if (tasitDegeri <= 651700) {
              _mtv =
                  (yas <= 3)
                      ? 16370
                      : (yas <= 6)
                      ? 12801
                      : (yas <= 11)
                      ? 7523
                      : (yas <= 15)
                      ? 4589
                      : 1777;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 17866
                      : (yas <= 6)
                      ? 13956
                      : (yas <= 11)
                      ? 8218
                      : (yas <= 15)
                      ? 5014
                      : 1940;
            }
          }
        } else if (motorHacmi <= 2000) {
          if (_tesciltarihi == 'Öncesi') {
            _mtv =
                (yas <= 3)
                    ? 23454
                    : (yas <= 6)
                    ? 18057
                    : (yas <= 11)
                    ? 10613
                    : (yas <= 15)
                    ? 6314
                    : 2487;
          } else {
            if (tasitDegeri <= 651700) {
              _mtv =
                  (yas <= 3)
                      ? 25792
                      : (yas <= 6)
                      ? 19862
                      : (yas <= 11)
                      ? 11674
                      : (yas <= 15)
                      ? 6948
                      : 2731;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 28142
                      : (yas <= 6)
                      ? 21677
                      : (yas <= 11)
                      ? 12734
                      : (yas <= 15)
                      ? 7577
                      : 2982;
            }
          }
        } else if (motorHacmi <= 2500) {
          if (_tesciltarihi == 'Öncesi') {
            _mtv =
                (yas <= 3)
                    ? 35175
                    : (yas <= 6)
                    ? 25534
                    : (yas <= 11)
                    ? 15954
                    : (yas <= 15)
                    ? 9528
                    : 3766;
          } else {
            if (tasitDegeri <= 813900) {
              _mtv =
                  (yas <= 3)
                      ? 38695
                      : (yas <= 6)
                      ? 28090
                      : (yas <= 11)
                      ? 17549
                      : (yas <= 15)
                      ? 10480
                      : 4145;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 42217
                      : (yas <= 6)
                      ? 30642
                      : (yas <= 11)
                      ? 19141
                      : (yas <= 15)
                      ? 11439
                      : 4522;
            }
          }
        } else if (motorHacmi <= 3000) {
          if (_tesciltarihi == 'Öncesi') {
            _mtv =
                (yas <= 3)
                    ? 49052
                    : (yas <= 6)
                    ? 42669
                    : (yas <= 11)
                    ? 26654
                    : (yas <= 15)
                    ? 14329
                    : 5259;
          } else {
            if (tasitDegeri <= 1628900) {
              _mtv =
                  (yas <= 3)
                      ? 53952
                      : (yas <= 6)
                      ? 46942
                      : (yas <= 11)
                      ? 29322
                      : (yas <= 15)
                      ? 15770
                      : 5780;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 58864
                      : (yas <= 6)
                      ? 51203
                      : (yas <= 11)
                      ? 31991
                      : (yas <= 15)
                      ? 17206
                      : 6308;
            }
          }
        } else if (motorHacmi <= 3500) {
          if (_tesciltarihi == 'Öncesi') {
            _mtv =
                (yas <= 3)
                    ? 74703
                    : (yas <= 6)
                    ? 67218
                    : (yas <= 11)
                    ? 40486
                    : (yas <= 15)
                    ? 20203
                    : 7409;
          } else {
            if (tasitDegeri <= 1628900) {
              _mtv =
                  (yas <= 3)
                      ? 82173
                      : (yas <= 6)
                      ? 73942
                      : (yas <= 11)
                      ? 44537
                      : (yas <= 15)
                      ? 22231
                      : 8142;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 89652
                      : (yas <= 6)
                      ? 80656
                      : (yas <= 11)
                      ? 48585
                      : (yas <= 15)
                      ? 24245
                      : 8893;
            }
          }
        } else if (motorHacmi <= 4000) {
          if (_tesciltarihi == 'Öncesi') {
            _mtv =
                (yas <= 3)
                    ? 117462
                    : (yas <= 6)
                    ? 101427
                    : (yas <= 11)
                    ? 59730
                    : (yas <= 15)
                    ? 26654
                    : 10613;
          } else {
            if (tasitDegeri <= 2607700) {
              _mtv =
                  (yas <= 3)
                      ? 129201
                      : (yas <= 6)
                      ? 111570
                      : (yas <= 11)
                      ? 65702
                      : (yas <= 15)
                      ? 29322
                      : 11674;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 140960
                      : (yas <= 6)
                      ? 121707
                      : (yas <= 11)
                      ? 71687
                      : (yas <= 15)
                      ? 31991
                      : 12734;
            }
          }
        } else {
          if (_tesciltarihi == 'Öncesi') {
            _mtv =
                (yas <= 3)
                    ? 192250
                    : (yas <= 6)
                    ? 144166
                    : (yas <= 11)
                    ? 85377
                    : (yas <= 15)
                    ? 38363
                    : 14885;
          } else {
            if (tasitDegeri <= 3096500) {
              _mtv =
                  (yas <= 3)
                      ? 211479
                      : (yas <= 6)
                      ? 158577
                      : (yas <= 11)
                      ? 93917
                      : (yas <= 15)
                      ? 42208
                      : 16370;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 230698
                      : (yas <= 6)
                      ? 172998
                      : (yas <= 11)
                      ? 102458
                      : (yas <= 15)
                      ? 46044
                      : 17866;
            }
          }
        }
      }
      if (elektrik == "Evet") {
        // Elektrikli araç için MTV hesaplama
        if (motorHacmi <= 70) {
          if (tasitDegeri <= 114000) {
            _mtv = (yas <= 3) ? 1207 : 840;
          } else if (tasitDegeri <= 199700) {
            _mtv = (yas <= 3) ? 1324 : 926;
          } else {
            _mtv = (yas <= 3) ? 1449 : 1011;
          }
        } else if (motorHacmi <= 85) {
          if (tasitDegeri <= 114000) {
            _mtv = (yas <= 3) ? 2104 : 1577;
          } else if (tasitDegeri <= 199700) {
            _mtv = (yas <= 3) ? 2314 : 2314;
          } else {
            _mtv = (yas <= 3) ? 2528 : 1894;
          }
        } else if (motorHacmi <= 105) {
          if (tasitDegeri <= 285800) {
            _mtv = (yas <= 3) ? 4090 : 3199;
          } else {
            _mtv = (yas <= 3) ? 4463 : 3491;
          }
        } else if (motorHacmi <= 120) {
          if (tasitDegeri <= 285800) {
            _mtv = (yas <= 3) ? 6446 : 4964;
          } else {
            _mtv = (yas <= 3) ? 7032 : 5420;
          }
        } else if (motorHacmi <= 150) {
          if (tasitDegeri <= 356900) {
            _mtv = (yas <= 3) ? 9673 : 7020;
          } else {
            _mtv = (yas <= 3) ? 10554 : 7659;
          }
        } else if (motorHacmi <= 180) {
          if (tasitDegeri <= 714300) {
            _mtv = (yas <= 3) ? 13487 : 11733;
          } else {
            _mtv = (yas <= 3) ? 14716 : 12801;
          }
        } else if (motorHacmi <= 210) {
          if (tasitDegeri <= 714300) {
            _mtv = (yas <= 3) ? 20537 : 18484;
          } else {
            _mtv = (yas <= 3) ? 22411 : 18797;
          }
        } else if (motorHacmi <= 240) {
          if (tasitDegeri <= 1143000) {
            _mtv = (yas <= 3) ? 32300 : 27892;
          } else {
            _mtv = (yas <= 3) ? 35241 : 30426;
          }
        } else {
          if (tasitDegeri <= 1357700) {
            _mtv = (yas <= 3) ? 52868 : 39642;
          } else {
            _mtv = (yas <= 3) ? 57671 : 43248;
          }
        }
      }
    }
    if (arac == 'Motosiklet') {
      if (elektrik == "Hayır") {
        _mtv =
            (motorHacmi <= 99)
                ? 0
                : (motorHacmi <= 250)
                ? (yas <= 3
                    ? 899
                    : yas <= 6
                    ? 672
                    : yas <= 11
                    ? 496
                    : yas <= 15
                    ? 305
                    : 115)
                : (motorHacmi <= 650)
                ? (yas <= 3
                    ? 1862
                    : yas <= 6
                    ? 1409
                    : yas <= 11
                    ? 899
                    : yas <= 15
                    ? 496
                    : 305)
                : (motorHacmi <= 1200)
                ? (yas <= 3
                    ? 4808
                    : yas <= 6
                    ? 2857
                    : yas <= 11
                    ? 1409
                    : yas <= 15
                    ? 899
                    : 496)
                : (yas <= 3
                    ? 11666
                    : yas <= 6
                    ? 7707
                    : yas <= 11
                    ? 4808
                    : yas <= 15
                    ? 3817
                    : 1862);
      } else if (elektrik == "Evet") {
        _mtv =
            (motorHacmi >= 6 && motorHacmi <= 15)
                ? (yas <= 3
                    ? 449
                    : yas <= 6
                    ? 336
                    : yas <= 11
                    ? 248
                    : yas <= 15
                    ? 152
                    : 57)
                : (motorHacmi <= 40)
                ? (yas <= 3
                    ? 931
                    : yas <= 6
                    ? 704
                    : yas <= 11
                    ? 449
                    : yas <= 15
                    ? 248
                    : 152)
                : (motorHacmi <= 60)
                ? (yas <= 3
                    ? 2404
                    : yas <= 6
                    ? 1428
                    : yas <= 11
                    ? 704
                    : yas <= 15
                    ? 449
                    : 248)
                : (yas <= 3
                    ? 5833
                    : yas <= 6
                    ? 3853
                    : yas <= 11
                    ? 2404
                    : yas <= 15
                    ? 1908
                    : 931);
      }
    } else if (arac == 'Minibüs') {
      _mtv =
          (elektrik == "Hayır")
              ? (yas <= 6
                  ? 5780
                  : yas <= 15
                  ? 3817
                  : 1862)
              : (elektrik == "Evet")
              ? (yas <= 6
                  ? 1445
                  : yas <= 15
                  ? 954
                  : 465)
              : _mtv;
    } else if (arac == 'Panelvan') {
      _mtv =
          (elektrik == "Hayır")
              ? (motorHacmi <= 1900)
                  ? (yas <= 6
                      ? 7707
                      : yas <= 15
                      ? 4808
                      : 2857)
                  : (yas <= 6
                      ? 11666
                      : yas <= 15
                      ? 7707
                      : 4808)
              : (elektrik == "Evet")
              ? (motorHacmi <= 1900)
                  ? (yas <= 6
                      ? 1926
                      : yas <= 15
                      ? 1202
                      : 714)
                  : (yas <= 6
                      ? 2916
                      : yas <= 15
                      ? 1926
                      : 1202)
              : _mtv;
    } else if (arac == 'Otobüs') {
      _mtv =
          (elektrik == "Hayır")
              ? (motorHacmi <= 25)
                  ? (yas <= 6
                      ? 14603
                      : yas <= 15
                      ? 8720
                      : 3817)
                  : (motorHacmi <= 35)
                  ? (yas <= 6
                      ? 17513
                      : yas <= 15
                      ? 14603
                      : 5780)
                  : (motorHacmi <= 45)
                  ? (yas <= 6
                      ? 19489
                      : yas <= 15
                      ? 16530
                      : 7707)
                  : (yas <= 6
                      ? 23381
                      : yas <= 15
                      ? 19489
                      : 11666)
              : (elektrik == "Evet")
              ? (motorHacmi <= 25)
                  ? (yas <= 6
                      ? 3650
                      : yas <= 15
                      ? 2180
                      : 954)
                  : (motorHacmi <= 35)
                  ? (yas <= 6
                      ? 4378
                      : yas <= 15
                      ? 3650
                      : 1445)
                  : (motorHacmi <= 45)
                  ? (yas <= 6
                      ? 4872
                      : yas <= 15
                      ? 4132
                      : 1926)
                  : (yas <= 6
                      ? 5845
                      : yas <= 15
                      ? 4872
                      : 2916)
              : _mtv;
    } else if (arac == 'Kamyonet') {
      _mtv =
          (elektrik == "Hayır")
              ? (motorHacmi <= 1500)
                  ? (yas <= 6
                      ? 5182
                      : yas <= 15
                      ? 3442
                      : 1685)
                  : (motorHacmi <= 3500)
                  ? (yas <= 6
                      ? 10499
                      : yas <= 15
                      ? 6082
                      : 3442)
                  : (motorHacmi <= 5000)
                  ? (yas <= 6
                      ? 15774
                      : yas <= 15
                      ? 13129
                      : 5182)
                  : (motorHacmi <= 10000)
                  ? (yas <= 6
                      ? 17513
                      : yas <= 15
                      ? 14872
                      : 6971)
                  : (motorHacmi <= 20000)
                  ? (yas <= 6
                      ? 21048
                      : yas <= 15
                      ? 17513
                      : 10499)
                  : (yas <= 6
                      ? 26327
                      : yas <= 15
                      ? 21048
                      : 12231)
              : (elektrik == "Evet")
              ? (motorHacmi <= 1500)
                  ? (yas <= 6
                      ? 1295
                      : yas <= 15
                      ? 860
                      : 421)
                  : (motorHacmi <= 3500)
                  ? (yas <= 6
                      ? 2624
                      : yas <= 15
                      ? 1520
                      : 860)
                  : (motorHacmi <= 5000)
                  ? (yas <= 6
                      ? 3943
                      : yas <= 15
                      ? 3282
                      : 1295)
                  : (motorHacmi <= 10000)
                  ? (yas <= 6
                      ? 4378
                      : yas <= 15
                      ? 3718
                      : 1742)
                  : (motorHacmi <= 20000)
                  ? (yas <= 6
                      ? 5262
                      : yas <= 15
                      ? 4378
                      : 2624)
                  : (yas <= 6
                      ? 6581
                      : yas <= 15
                      ? 5262
                      : 3057)
              : _mtv;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MtvSon(
              mtv0: _aractipi,
              mtv1: _elektrikli,
              mtv2: _tesciltarihi,
              mtv3: yas.toString(),
              mtv4: motorHacmi.toString(),
              mtv5: tasitDegeri.toString(),
              mtv6: _mtv.toString(),
              mtv7: (_mtv / 2).toString(),
              mtv8: (_mtv / 2).toString(),
            ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoColumn(
            'MTV Nedir?',
            'Motorlu Taşıtlar Vergisi (MTV), araç sahiplerinin ödemesi gereken bir vergidir.',
          ),
          _buildInfoColumn(
            'MTV Ödenmezse Ne Olur?',
            'MTV ödenmezse, araç sahibine cezai yaptırımlar uygulanır.',
          ),
          _buildInfoColumn(
            'MTV Ödeme Tarihleri Ne Zaman?',
            'MTV ödeme tarihleri genellikle yılın ilk ve ikinci yarısında olur.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String header, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Renk.koyuMavi,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
