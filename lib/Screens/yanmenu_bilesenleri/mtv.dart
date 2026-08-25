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
  double _mtv = 0;
  int tasitDegeri = 0;
  String _tesciltarihi = 'Lütfen Seçiniz';
  String _elektrikli = "Hayır";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),
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
        dropdownColor: Colors.white,
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
        dropdownColor: Colors.white,
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
    } else if (_aractipi == 'Panelvan') {
      motorHacmiItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1900,
          child: Text('1900 cm³ ve altı', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1901,
          child: Text('1901 cm³ ve üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (_aractipi == 'Otobüs') {
      motorHacmiItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 25,
          child: Text('25 kişiye kadar', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 35,
          child: Text('26-35 kişiye kadar', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 45,
          child: Text('36-45 kişiye kadar', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 46,
          child: Text('46 kişi ve üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (_aractipi == 'Kamyonet') {
      motorHacmiItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1500,
          child: Text('1.500 kg\'a kadar', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 3500,
          child: Text('1.501 - 3.500 kg', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 5000,
          child: Text('3.501 - 5.000 kg', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 10000,
          child: Text('5.001 - 10.000 kg', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 20000,
          child: Text('10.001 - 20.000 kg', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 20001,
          child: Text('20.001 kg ve üzeri', style: Dekor.butonText_14_500siyah),
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
        dropdownColor: Colors.white,
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
          value: 309100,
          child: Text(
            '309.100 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 541500,
          child: Text(
            '309.100 TL ile 541.500 TL arası',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 541501,
          child: Text('541.501 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 1600) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 309100,
          child: Text(
            '309.100 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 541500,
          child: Text(
            '309.100 TL ile 541.500 TL arası',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 541501,
          child: Text('541.501 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 1800) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 775100,
          child: Text(
            '775.100 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 775101,
          child: Text('775.101 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 2000) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 775100,
          child: Text(
            '775.100 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 775101,
          child: Text('775.101 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 2500) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 968100,
          child: Text(
            '968.100 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 968101,
          child: Text('968.101 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 3000) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1937500,
          child: Text(
            '1.937.500 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 1937501,
          child: Text('1.937.501 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 3500) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 1937500,
          child: Text(
            '1.937.500 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 1937501,
          child: Text('1.937.501 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else if (motorHacmi <= 4000) {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 3101800,
          child: Text(
            '3.101.800 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 3101801,
          child: Text('3.101.801 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    } else {
      tasitDegeriItems = const [
        DropdownMenuItem(
          value: 0,
          child: Text('Lütfen Seçiniz', style: Dekor.butonText_14_500siyah),
        ),
        DropdownMenuItem(
          value: 3683200,
          child: Text(
            '3.683.200 TL ye kadar',
            style: Dekor.butonText_14_500siyah,
          ),
        ),
        DropdownMenuItem(
          value: 3683201,
          child: Text('3.683.201 TL üzeri', style: Dekor.butonText_14_500siyah),
        ),
      ];
    }

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
    _mtv = 0; // Sıfırla

    if (arac == 'Otomobil') {
      if (elektrik == "Hayır") {
        if (_tesciltarihi == 'Öncesi') {
          // (I/A) Sayılı Tarife - 31/12/2017 öncesi tesciller
          if (motorHacmi <= 1300) {
            _mtv =
                (yas <= 3)
                    ? 5750
                    : (yas <= 6)
                    ? 4010
                    : (yas <= 11)
                    ? 2238
                    : (yas <= 15)
                    ? 1689
                    : 593;
          } else if (motorHacmi <= 1600) {
            _mtv =
                (yas <= 3)
                    ? 10016
                    : (yas <= 6)
                    ? 7510
                    : (yas <= 11)
                    ? 4354
                    : (yas <= 15)
                    ? 3077
                    : 1181;
          } else if (motorHacmi <= 1800) {
            _mtv =
                (yas <= 3)
                    ? 17705
                    : (yas <= 6)
                    ? 13829
                    : (yas <= 11)
                    ? 8145
                    : (yas <= 15)
                    ? 4957
                    : 1917;
          } else if (motorHacmi <= 2000) {
            _mtv =
                (yas <= 3)
                    ? 27898
                    : (yas <= 6)
                    ? 21478
                    : (yas <= 11)
                    ? 12624
                    : (yas <= 15)
                    ? 7510
                    : 2958;
          } else if (motorHacmi <= 2500) {
            _mtv =
                (yas <= 3)
                    ? 41840
                    : (yas <= 6)
                    ? 30372
                    : (yas <= 11)
                    ? 18977
                    : (yas <= 15)
                    ? 11333
                    : 4479;
          } else if (motorHacmi <= 3000) {
            _mtv =
                (yas <= 3)
                    ? 58347
                    : (yas <= 6)
                    ? 50754
                    : (yas <= 11)
                    ? 31704
                    : (yas <= 15)
                    ? 17044
                    : 6255;
          } else if (motorHacmi <= 3500) {
            _mtv =
                (yas <= 3)
                    ? 88859
                    : (yas <= 6)
                    ? 79955
                    : (yas <= 11)
                    ? 48158
                    : (yas <= 15)
                    ? 24031
                    : 8813;
          } else if (motorHacmi <= 4000) {
            _mtv =
                (yas <= 3)
                    ? 139721
                    : (yas <= 6)
                    ? 120647
                    : (yas <= 11)
                    ? 71048
                    : (yas <= 15)
                    ? 31704
                    : 12624;
          } else {
            _mtv =
                (yas <= 3)
                    ? 228681
                    : (yas <= 6)
                    ? 171485
                    : (yas <= 11)
                    ? 101555
                    : (yas <= 15)
                    ? 45632
                    : 17705;
          }
        } else {
          // (I) Sayılı Tarife - 1/1/2018 sonrası tesciller
          if (motorHacmi <= 1300) {
            if (tasitDegeri <= 309100) {
              _mtv =
                  (yas <= 3)
                      ? 5750
                      : (yas <= 6)
                      ? 4010
                      : (yas <= 11)
                      ? 2238
                      : (yas <= 15)
                      ? 1689
                      : 593;
            } else if (tasitDegeri <= 541500) {
              _mtv =
                  (yas <= 3)
                      ? 6319
                      : (yas <= 6)
                      ? 4409
                      : (yas <= 11)
                      ? 2459
                      : (yas <= 15)
                      ? 1861
                      : 655;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 6902
                      : (yas <= 6)
                      ? 4807
                      : (yas <= 11)
                      ? 2693
                      : (yas <= 15)
                      ? 2032
                      : 706;
            }
          } else if (motorHacmi <= 1600) {
            if (tasitDegeri <= 309100) {
              _mtv =
                  (yas <= 3)
                      ? 10016
                      : (yas <= 6)
                      ? 7510
                      : (yas <= 11)
                      ? 4354
                      : (yas <= 15)
                      ? 3077
                      : 1181;
            } else if (tasitDegeri <= 541500) {
              _mtv =
                  (yas <= 3)
                      ? 11023
                      : (yas <= 6)
                      ? 8264
                      : (yas <= 11)
                      ? 4794
                      : (yas <= 15)
                      ? 3375
                      : 1290;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 12028
                      : (yas <= 6)
                      ? 9012
                      : (yas <= 11)
                      ? 5220
                      : (yas <= 15)
                      ? 3685
                      : 1408;
            }
          } else if (motorHacmi <= 1800) {
            if (tasitDegeri <= 775100) {
              _mtv =
                  (yas <= 3)
                      ? 19472
                      : (yas <= 6)
                      ? 15226
                      : (yas <= 11)
                      ? 8948
                      : (yas <= 15)
                      ? 5458
                      : 2113;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 21251
                      : (yas <= 6)
                      ? 16600
                      : (yas <= 11)
                      ? 9775
                      : (yas <= 15)
                      ? 5964
                      : 2307;
            }
          } else if (motorHacmi <= 2000) {
            if (tasitDegeri <= 775100) {
              _mtv =
                  (yas <= 3)
                      ? 30679
                      : (yas <= 6)
                      ? 23625
                      : (yas <= 11)
                      ? 13886
                      : (yas <= 15)
                      ? 8264
                      : 3248;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 33474
                      : (yas <= 6)
                      ? 25784
                      : (yas <= 11)
                      ? 15147
                      : (yas <= 15)
                      ? 9012
                      : 3547;
            }
          } else if (motorHacmi <= 2500) {
            if (tasitDegeri <= 968100) {
              _mtv =
                  (yas <= 3)
                      ? 46027
                      : (yas <= 6)
                      ? 33413
                      : (yas <= 11)
                      ? 20874
                      : (yas <= 15)
                      ? 12465
                      : 4930;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 50217
                      : (yas <= 6)
                      ? 36448
                      : (yas <= 11)
                      ? 22768
                      : (yas <= 15)
                      ? 13606
                      : 5378;
            }
          } else if (motorHacmi <= 3000) {
            if (tasitDegeri <= 1937500) {
              _mtv =
                  (yas <= 3)
                      ? 64175
                      : (yas <= 6)
                      ? 55837
                      : (yas <= 11)
                      ? 34878
                      : (yas <= 15)
                      ? 18758
                      : 6875;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 70018
                      : (yas <= 6)
                      ? 60905
                      : (yas <= 11)
                      ? 38053
                      : (yas <= 15)
                      ? 20466
                      : 7503;
            }
          } else if (motorHacmi <= 3500) {
            if (tasitDegeri <= 1937500) {
              _mtv =
                  (yas <= 3)
                      ? 97744
                      : (yas <= 6)
                      ? 87954
                      : (yas <= 11)
                      ? 52976
                      : (yas <= 15)
                      ? 26443
                      : 9684;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 106641
                      : (yas <= 6)
                      ? 95940
                      : (yas <= 11)
                      ? 57791
                      : (yas <= 15)
                      ? 28839
                      : 10578;
            }
          } else if (motorHacmi <= 4000) {
            if (tasitDegeri <= 3101800) {
              _mtv =
                  (yas <= 3)
                      ? 153684
                      : (yas <= 6)
                      ? 132712
                      : (yas <= 11)
                      ? 78152
                      : (yas <= 15)
                      ? 34878
                      : 13886;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 167671
                      : (yas <= 6)
                      ? 144770
                      : (yas <= 11)
                      ? 85271
                      : (yas <= 15)
                      ? 38053
                      : 15147;
            }
          } else {
            if (tasitDegeri <= 3683200) {
              _mtv =
                  (yas <= 3)
                      ? 251554
                      : (yas <= 6)
                      ? 188627
                      : (yas <= 11)
                      ? 111714
                      : (yas <= 15)
                      ? 50206
                      : 19472;
            } else {
              _mtv =
                  (yas <= 3)
                      ? 274415
                      : (yas <= 6)
                      ? 205781
                      : (yas <= 11)
                      ? 121873
                      : (yas <= 15)
                      ? 54769
                      : 21251;
            }
          }
        }
      } else if (elektrik == "Evet") {
        // Elektrikli araçlar için %25 oranı uygulanır
        double baseMtv = 0;

        // Elektrikli araçlar için motor gücüne göre baz fiyat belirleme
        if (motorHacmi <= 70) {
          baseMtv = 5750; // 70 kW ve altı için temel fiyat
        } else if (motorHacmi <= 85) {
          baseMtv = 10016; // 71-85 kW için temel fiyat
        } else if (motorHacmi <= 105) {
          baseMtv = 19472; // 86-105 kW için temel fiyat
        } else if (motorHacmi <= 120) {
          baseMtv = 30679; // 106-120 kW için temel fiyat
        } else if (motorHacmi <= 150) {
          baseMtv = 46027; // 121-150 kW için temel fiyat
        } else if (motorHacmi <= 180) {
          baseMtv = 64175; // 151-180 kW için temel fiyat
        } else if (motorHacmi <= 210) {
          baseMtv = 97744; // 181-210 kW için temel fiyat
        } else if (motorHacmi <= 240) {
          baseMtv = 153684; // 211-240 kW için temel fiyat
        } else {
          baseMtv = 251554; // 241 kW ve üzeri için temel fiyat
        }

        // Yaşa göre ayarlama (basitleştirilmiş)
        if (yas <= 3) {
          _mtv = baseMtv * 0.25;
        } else if (yas <= 6) {
          _mtv = baseMtv * 0.7 * 0.25;
        } else if (yas <= 11) {
          _mtv = baseMtv * 0.4 * 0.25;
        } else if (yas <= 15) {
          _mtv = baseMtv * 0.2 * 0.25;
        } else {
          _mtv = baseMtv * 0.08 * 0.25;
        }
      }
    } else if (arac == 'Motosiklet') {
      if (elektrik == "Hayır") {
        _mtv =
            (motorHacmi <= 250)
                ? (yas <= 3
                    ? 1069
                    : yas <= 6
                    ? 799
                    : yas <= 11
                    ? 589
                    : yas <= 15
                    ? 362
                    : 136)
                : (motorHacmi <= 650)
                ? (yas <= 3
                    ? 2214
                    : yas <= 6
                    ? 1676
                    : yas <= 11
                    ? 1069
                    : yas <= 15
                    ? 589
                    : 362)
                : (motorHacmi <= 1200)
                ? (yas <= 3
                    ? 5719
                    : yas <= 6
                    ? 3398
                    : yas <= 11
                    ? 1676
                    : yas <= 15
                    ? 1069
                    : 589)
                : (yas <= 3
                    ? 13876
                    : yas <= 6
                    ? 9167
                    : yas <= 11
                    ? 5719
                    : yas <= 15
                    ? 4540
                    : 2214);
      } else if (elektrik == "Evet") {
        // Elektrikli motosikletler için %25 oranı
        if (motorHacmi >= 6 && motorHacmi <= 15) {
          _mtv =
              (yas <= 3
                  ? 1069
                  : yas <= 6
                  ? 799
                  : yas <= 11
                  ? 589
                  : yas <= 15
                  ? 362
                  : 136) *
              0.25;
        } else if (motorHacmi <= 40) {
          _mtv =
              (yas <= 3
                  ? 2214
                  : yas <= 6
                  ? 1676
                  : yas <= 11
                  ? 1069
                  : yas <= 15
                  ? 589
                  : 362) *
              0.25;
        } else if (motorHacmi <= 60) {
          _mtv =
              (yas <= 3
                  ? 5719
                  : yas <= 6
                  ? 3398
                  : yas <= 11
                  ? 1676
                  : yas <= 15
                  ? 1069
                  : 589) *
              0.25;
        } else {
          _mtv =
              (yas <= 3
                  ? 13876
                  : yas <= 6
                  ? 9167
                  : yas <= 11
                  ? 5719
                  : yas <= 15
                  ? 4540
                  : 2214) *
              0.25;
        }
      }
    } else if (arac == 'Minibüs') {
      double baseMtv =
          (yas <= 6)
              ? 6875
              : (yas <= 15)
              ? 4540
              : 2214;
      _mtv = (elektrik == "Hayır") ? baseMtv : baseMtv * 0.25;
    } else if (arac == 'Panelvan') {
      double baseMtv;
      if (motorHacmi <= 1900) {
        baseMtv =
            (yas <= 6)
                ? 9167
                : (yas <= 15)
                ? 5719
                : 3398;
      } else {
        baseMtv =
            (yas <= 6)
                ? 13876
                : (yas <= 15)
                ? 9167
                : 5719;
      }
      _mtv = (elektrik == "Hayır") ? baseMtv : baseMtv * 0.25;
    } else if (arac == 'Otobüs') {
      double baseMtv;
      if (motorHacmi <= 25) {
        baseMtv =
            (yas <= 6)
                ? 17370
                : (yas <= 15)
                ? 10372
                : 4540;
      } else if (motorHacmi <= 35) {
        baseMtv =
            (yas <= 6)
                ? 20831
                : (yas <= 15)
                ? 17370
                : 6875;
      } else if (motorHacmi <= 45) {
        baseMtv =
            (yas <= 6)
                ? 23182
                : (yas <= 15)
                ? 19662
                : 9167;
      } else {
        baseMtv =
            (yas <= 6)
                ? 27811
                : (yas <= 15)
                ? 23182
                : 13876;
      }
      _mtv = (elektrik == "Hayır") ? baseMtv : baseMtv * 0.25;
    } else if (arac == 'Kamyonet') {
      double baseMtv;
      if (motorHacmi <= 1500) {
        baseMtv =
            (yas <= 6)
                ? 6163
                : (yas <= 15)
                ? 4094
                : 2004;
      } else if (motorHacmi <= 3500) {
        baseMtv =
            (yas <= 6)
                ? 12488
                : (yas <= 15)
                ? 7234
                : 4094;
      } else if (motorHacmi <= 5000) {
        baseMtv =
            (yas <= 6)
                ? 18763
                : (yas <= 15)
                ? 15616
                : 6163;
      } else if (motorHacmi <= 10000) {
        baseMtv =
            (yas <= 6)
                ? 20831
                : (yas <= 15)
                ? 17690
                : 8292;
      } else if (motorHacmi <= 20000) {
        baseMtv =
            (yas <= 6)
                ? 25036
                : (yas <= 15)
                ? 20831
                : 12488;
      } else {
        baseMtv =
            (yas <= 6)
                ? 31315
                : (yas <= 15)
                ? 25036
                : 14548;
      }
      _mtv = (elektrik == "Hayır") ? baseMtv : baseMtv * 0.25;
    }

    // MTV'yi tam sayıya yuvarla
    int mtvInt = _mtv.round();

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
              mtv6: mtvInt.toString(),
              mtv7: (mtvInt / 2).round().toString(),
              mtv8: (mtvInt / 2).round().toString(),
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
            color: Renk.pastelKoyuMavi,
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
