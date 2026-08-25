import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Nekadar extends StatefulWidget {
  const Nekadar({super.key});

  @override
  State<Nekadar> createState() => _NekadarState();
}

class _NekadarState extends State<Nekadar> {
  final TextEditingController _initialAmountController = TextEditingController(
    text: "0",
  );
  DateTime? _startDate;
  DateTime? _endDate;
  double _result = 0.0;
  double _totalInflationChange = 0.0;

  final Map<String, double> _tufeRates = {
    // 2026 yılı için TÜFE oranları
    "2026-01": 0.0,
    "2026-02": 0.0,
    "2026-03": 0.0,
    "2026-04": 0.0,
    "2026-05": 0.0,
    "2026-06": 0.0,
    "2026-07": 0.0,
    "2026-08": 0.0,
    "2026-09": 0.0,
    "2026-10": 0.0,
    "2026-11": 0.0,
    "2026-12": 0.0,

    // 2025 yılı için TÜFE oranları
    "2025-01": 5.08,
    "2025-02": 2.27,
    "2025-03": 2.46,
    "2025-04": 3.0,
    "2025-05": 1.53,
    "2025-06": 1.37,
    "2025-07": 2.06,
    "2025-08": 2.04,
    "2025-09": 3.23,
    "2025-10": 2.55,
    "2025-11": 0.87,
    "2025-12": 0.0,

    // 2024 yılı için TÜFE oranları
    "2024-01": 6.70,
    "2024-02": 4.53,
    "2024-03": 3.16,
    "2024-04": 3.18,
    "2024-05": 3.37,
    "2024-06": 1.64,
    "2024-07": 3.23,
    "2024-08": 2.47,
    "2024-09": 2.97,
    "2024-10": 2.88,
    "2024-11": 2.24,
    "2024-12": 1.03,

    // 2023 yılı için TÜFE oranları
    "2023-01": 6.65,
    "2023-02": 3.15,
    "2023-03": 2.29,
    "2023-04": 2.39,
    "2023-05": 0.04,
    "2023-06": 3.92,
    "2023-07": 9.49,
    "2023-08": 9.09,
    "2023-09": 4.75,
    "2023-10": 3.43,
    "2023-11": 3.28,
    "2023-12": 2.93,

    // 2022 yılı için TÜFE oranları
    "2022-01": 11.10,
    "2022-02": 4.81,
    "2022-03": 5.46,
    "2022-04": 7.25,
    "2022-05": 2.98,
    "2022-06": 4.95,
    "2022-07": 2.37,
    "2022-08": 1.46,
    "2022-09": 3.08,
    "2022-10": 3.54,
    "2022-11": -1.44,
    "2022-12": -0.40,

    // 2021 yılı için TÜFE oranları
    "2021-01": 1.68,
    "2021-02": 0.91,
    "2021-03": 1.08,
    "2021-04": 1.68,
    "2021-05": 0.89,
    "2021-06": 1.94,
    "2021-07": 1.80,
    "2021-08": 1.12,
    "2021-09": 1.25,
    "2021-10": 2.39,
    "2021-11": 3.51,
    "2021-12": 13.58,

    // 2020 yılı için TÜFE oranları
    "2020-01": 1.35,
    "2020-02": 0.35,
    "2020-03": 0.57,
    "2020-04": 0.85,
    "2020-05": 1.36,
    "2020-06": 1.13,
    "2020-07": 0.58,
    "2020-08": 0.86,
    "2020-09": 0.97,
    "2020-10": 2.13,
    "2020-11": 2.30,
    "2020-12": 1.25,

    // 2019 yılı için TÜFE oranları
    "2019-01": 1.06,
    "2019-02": 0.16,
    "2019-03": 1.03,
    "2019-04": 1.69,
    "2019-05": 0.95,
    "2019-06": 0.03,
    "2019-07": 1.36,
    "2019-08": 0.86,
    "2019-09": 0.99,
    "2019-10": 2.00,
    "2019-11": 0.38,
    "2019-12": 0.74,

    // 2018 yılı için TÜFE oranları
    "2018-01": 1.02,
    "2018-02": 0.73,
    "2018-03": 0.99,
    "2018-04": 1.87,
    "2018-05": 1.62,
    "2018-06": 2.61,
    "2018-07": 0.55,
    "2018-08": 2.30,
    "2018-09": 6.30,
    "2018-10": 2.67,
    "2018-11": -1.44,
    "2018-12": -0.40,

    // 2017 yılı için TÜFE oranları
    "2017-01": 2.46,
    "2017-02": 0.81,
    "2017-03": 1.02,
    "2017-04": 1.31,
    "2017-05": 0.45,
    "2017-06": -0.27,
    "2017-07": 0.15,
    "2017-08": 0.52,
    "2017-09": 0.65,
    "2017-10": 2.08,
    "2017-11": 1.49,
    "2017-12": 0.69,

    // 2016 yılı için TÜFE oranları
    "2016-01": 1.82,
    "2016-02": -0.02,
    "2016-03": -0.04,
    "2016-04": 0.78,
    "2016-05": 0.58,
    "2016-06": 0.47,
    "2016-07": 1.16,
    "2016-08": -0.29,
    "2016-09": 0.18,
    "2016-10": 1.44,
    "2016-11": 0.52,
    "2016-12": 1.64,

    // 2015 yılı için TÜFE oranları
    "2015-01": 1.10,
    "2015-02": 0.71,
    "2015-03": 1.19,
    "2015-04": 1.63,
    "2015-05": 0.56,
    "2015-06": -0.51,
    "2015-07": 0.09,
    "2015-08": 0.40,
    "2015-09": 0.89,
    "2015-10": 1.55,
    "2015-11": 0.67,
    "2015-12": 0.21,

    // 2014 yılı için TÜFE oranları
    "2014-01": 1.98,
    "2014-02": 0.43,
    "2014-03": 1.13,
    "2014-04": 1.34,
    "2014-05": 0.40,
    "2014-06": 0.31,
    "2014-07": 0.45,
    "2014-08": 0.09,
    "2014-09": 0.14,
    "2014-10": 1.90,
    "2014-11": 0.18,
    "2014-12": -0.44,

    // 2013 yılı için TÜFE oranları
    "2013-01": 1.65,
    "2013-02": 0.30,
    "2013-03": 0.66,
    "2013-04": 0.42,
    "2013-05": 0.15,
    "2013-06": 0.76,
    "2013-07": 0.31,
    "2013-08": -0.10,
    "2013-09": 0.77,
    "2013-10": 1.80,
    "2013-11": 0.01,
    "2013-12": 0.46,

    // 2012 yılı için TÜFE oranları
    "2012-01": 0.56,
    "2012-02": 0.56,
    "2012-03": 0.41,
    "2012-04": 1.52,
    "2012-05": -0.21,
    "2012-06": -0.90,
    "2012-07": -0.23,
    "2012-08": 0.56,
    "2012-09": 1.03,
    "2012-10": 1.96,
    "2012-11": 0.38,
    "2012-12": 0.38,

    // 2011 yılı için TÜFE oranları
    "2011-01": 0.41,
    "2011-02": 0.73,
    "2011-03": 0.42,
    "2011-04": 0.87,
    "2011-05": 2.42,
    "2011-06": -1.43,
    "2011-07": -0.41,
    "2011-08": 0.73,
    "2011-09": 0.75,
    "2011-10": 3.27,
    "2011-11": 1.73,
    "2011-12": 0.58,

    // 2010 yılı için TÜFE oranları
    "2010-01": 1.85,
    "2010-02": 1.45,
    "2010-03": 0.58,
    "2010-04": 0.60,
    "2010-05": -0.36,
    "2010-06": -0.56,
    "2010-07": -0.48,
    "2010-08": 0.40,
    "2010-09": 1.23,
    "2010-10": 1.83,
    "2010-11": 0.03,
    "2010-12": -0.30,

    // 2009 yılı için TÜFE oranları
    "2009-01": 0.29,
    "2009-02": -0.34,
    "2009-03": 1.10,
    "2009-04": 0.02,
    "2009-05": 0.64,
    "2009-06": 0.11,
    "2009-07": 0.25,
    "2009-08": -0.30,
    "2009-09": 0.39,
    "2009-10": 2.41,
    "2009-11": 1.27,
    "2009-12": 0.53,

    // 2008 yılı için TÜFE oranları
    "2008-01": 0.80,
    "2008-02": 1.29,
    "2008-03": 0.96,
    "2008-04": 1.68,
    "2008-05": 1.49,
    "2008-06": -0.36,
    "2008-07": 0.58,
    "2008-08": 0.02,
    "2008-09": 0.45,
    "2008-10": 2.60,
    "2008-11": 0.83,
    "2008-12": -0.41,

    // 2007 yılı için TÜFE oranları
    "2007-01": -0.05,
    "2007-02": 0.43,
    "2007-03": 0.92,
    "2007-04": 0.85,
    "2007-05": 0.36,
    "2007-06": 0.02,
    "2007-07": 0.44,
    "2007-08": 0.37,
    "2007-09": 0.68,
    "2007-10": 1.36,
    "2007-11": 0.45,
    "2007-12": 0.14,

    // 2006 yılı için TÜFE oranları
    "2006-01": 0.80,
    "2006-02": 0.63,
    "2006-03": 0.64,
    "2006-04": 0.42,
    "2006-05": 0.38,
    "2006-06": 0.66,
    "2006-07": 0.61,
    "2006-08": 0.70,
    "2006-09": 0.55,
    "2006-10": 0.71,
    "2006-11": 0.36,
    "2006-12": 0.43,

    // 2005 yılı için TÜFE oranları
    "2005-01": 0.71,
    "2005-02": 0.55,
    "2005-03": 0.51,
    "2005-04": 0.64,
    "2005-05": 0.33,
    "2005-06": 0.45,
    "2005-07": 0.67,
    "2005-08": 0.39,
    "2005-09": 0.54,
    "2005-10": 0.62,
    "2005-11": 0.49,
    "2005-12": 0.55,
  };
  String sonuctext = "";
  void calculateFutureValue() {
    double initialAmount = double.tryParse(_initialAmountController.text) ?? 0;
    double futureValue = initialAmount;
    double totalInflationFactor = 1.0; // Toplam enflasyon faktörünü başlat
    _totalInflationChange = 0.0; // Toplam enflasyon değişimini sıfırla

    if (_startDate != null && _endDate != null) {
      DateTime currentDate = _startDate!;
      while (currentDate.isBefore(_endDate!) ||
          currentDate.isAtSameMomentAs(_endDate!)) {
        String key =
            "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}";
        if (_tufeRates.containsKey(key)) {
          double tufeRate = _tufeRates[key]!;

          // Enflasyon oranını bileşik olarak uygula
          totalInflationFactor *= (1 + tufeRate / 100);
        }
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }

      // Gelecekteki değeri hesapla
      futureValue *= totalInflationFactor;

      double change = futureValue - initialAmount; // B - A
      _totalInflationChange =
          (change / initialAmount) * 100; // (B - A) / A * 100

      // Sonucu istediğiniz formatta oluşturun
      String startDateFormatted = DateFormat(
        'MMMM yyyy',
        'tr_TR',
      ).format(_startDate!); // Türkçe format
      String endDateFormatted = DateFormat(
        'MMMM yyyy',
        'tr_TR',
      ).format(_endDate!); // Türkçe format
      sonuctext =
          "$startDateFormatted tarihindeki ${NumberFormat("#,##0.00", "tr_TR").format(initialAmount)} TL olan mal sepeti $endDateFormatted tarihinde ${NumberFormat("#,##0.00", "tr_TR").format(futureValue)} TL olmaktadır.";

      setState(() {
        _result = futureValue;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          // Eğer başlangıç tarihi seçiliyorsa
          if (_endDate != null && picked.isAfter(_endDate!)) {
            Mesaj.altmesaj(
              context,
              "Başlangıç tarihi, bitiş tarihinden sonra olamaz.",
              Colors.red,
            );
          } else {
            _startDate = picked; // Başlangıç tarihini ayarla
          }
        } else {
          // Eğer bitiş tarihi seçiliyorsa
          if (_startDate != null && picked.isBefore(_startDate!)) {
            Mesaj.altmesaj(
              context,
              "Bitiş tarihi, başlangıç tarihinden önce olamaz.",
              Colors.red,
            );
          } else {
            _endDate = picked; // Bitiş tarihini ayarla
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),

        title: const Text("Değer Kaybı Hesapla"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: MetinKutusu(
                        controller: _initialAmountController,
                        labelText: "Başlangıç Miktarı (TL)",
                        hintText: '0,00 TL',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {},
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                " Başlangıç Tarihi:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Renk.pastelKoyuMavi,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: true,
                              ),
                              TextButton(
                                onPressed: () => _selectDate(context, true),
                                child: Text(
                                  _startDate == null
                                      ? 'Tarih Seçin'
                                      : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_startDate!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Dekor.cizgi15,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              " Bitiş Tarihi:",
                              style: TextStyle(
                                fontSize: 14,
                                color: Renk.pastelKoyuMavi,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: true,
                            ),
                            TextButton(
                              onPressed: () => _selectDate(context, false),
                              child: Text(
                                _endDate == null
                                    ? 'Tarih Seçin'
                                    : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_endDate!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const RepaintBoundary(child: YerelReklamuc()),
                    Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 30),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                calculateFutureValue();
                              },
                              child: Renk.buton("Hesapla", 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Yansatirikili.satir(
                      'Güncel Değer:',
                      '${NumberFormat("#,##0.00", "tr_TR").format(_result)} TL',
                      Renk.pastelKoyuMavi,
                    ),
                    Dekor.cizgi15,
                    Yansatirikili.satir(
                      'Toplam Endeks Değişim Oranı:',
                      '${NumberFormat("#,##0.00", "tr_TR").format(_totalInflationChange)} %',
                      Renk.pastelKoyuMavi,
                    ),
                    Dekor.cizgi15,
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 10,
                        top: 5,
                      ),
                      child: _buildInfoColumn("Sonuç :", sonuctext),
                    ),

                    bilgi(),
                  ],
                ),
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklam()),
        ],
      ),
    );
  }

  Widget bilgi() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 25, left: 5, right: 5),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildInfoColumn(
            'Parasal Değer Hesaplama',
            'Parasal Değer Hesaplama bir tarihteki belli bir miktar paranın başka bir tarihte ne kadara denk geldiğini kolayca hesaplayabilirsiniz. Parasal değer güncelleme için paranın hangi dönemde ne kadar olduğunu ve hangi tarihteki değerini öğrenmek istediğinizi hesaplama aracına girdikten sonra hesapla butonuna basınız.',
          ),
          _buildInfoColumn(
            'Enflasyon nedir?',
            'Ekonomide para şişkinliği anlamında kullanılmaktadır ve fiyatlar genel seviyesindeki artışı ifade etmektedir.Deflasyon ise enflasyonun tam tersidir ve belirli bir dönemde fiyatlar genel seviyesindeki düşüşü ifade etmektedir. Negatif enflasyon da deflasyon anlamına gelmektedir.',
          ),
          _buildInfoColumn(
            'TÜFE nedir?',
            'Tüketici fiyat endeksinin kısaltmasıdır. Her ayın ilk haftasında bir önceki ay için hesaplanan endeks verileri TÜİK (Türkiye İstatistik Kurumu) tarafından açıklanmaktadır.',
          ),
          _buildInfoColumn(
            'Paranın değer kaybı nasıl hesaplanır?',
            'Her ay için TÜİK tarafından açıklanan Tüketici Fiyat Endeksi (TÜFE) verileri oranlanarak iki farklı tarih arasındaki endeks değişim oranı bulunmaktadır. İlgili mal sepeti tutarının bu oranda artırılması veya azaltılması yoluyla aynı mal sepetinin ilgili tarihteki parasal değeri de hesaplanmış olur.',
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
