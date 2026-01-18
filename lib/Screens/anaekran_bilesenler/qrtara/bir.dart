import 'dart:async';
import 'dart:convert';

import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/qrtara/iki.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class QrGiris extends StatefulWidget {
  const QrGiris({super.key});

  @override
  State<QrGiris> createState() => _Buton();
}

class _Buton extends State<QrGiris> {
  List<String> qrAdListe = [];
  List<String> qrUrlListe = [];
  late Future<void> _qrFuture;

  @override
  void initState() {
    super.initState();

    _qrFuture = _qrCagir();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const Anasayfa(pozisyon: 0, tarihyenile: ""),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Renk.pastelKoyuMavi),

          title: const Text("Qr Kod Tarama"),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RepaintBoundary(child: YerelReklamuc()),
                ),
                const Text(
                  'Tarama Butonuna Basarak Tarama İşlemine Başlayabilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Renk.pastelKoyuMavi,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: _ustButonlar(),
                ),
                _qrListeBaslik(),
                const SizedBox(height: 15),
                FutureBuilder(
                  future: _qrFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return _qrGirListe();
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
        const RepaintBoundary(child: BannerReklamuc()),
      ],
    );
  }

  Future<void> _qrCagir() async {
    final prefs = await SharedPreferences.getInstance();
    String qrAdJsonCagir = prefs.getString('qrAd') ?? '[]';
    String qrUrlJsonCagir = prefs.getString('qrUrl') ?? '[]';

    qrAdListe = List<String>.from(jsonDecode(qrAdJsonCagir));
    qrUrlListe = List<String>.from(jsonDecode(qrUrlJsonCagir));
  }

  Widget _ustButonlar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Tarama()),
                );
              },
              child: Renk.buton('Taramayı Başlat', 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrListeBaslik() {
    return Container(
      height: 40,
      color: Renk.pastelKoyuMavi.withValues(alpha: 0.06),
      child: const Align(
        alignment: Alignment.center,
        child: Text(
          "Kayıtlı Tarama Listesi",
          style: TextStyle(
            fontSize: 16,
            color: Renk.pastelKoyuMavi,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _qrGirListe() {
    if (qrAdListe.isEmpty) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            "Kayıtlı qr kod adresi bulunmamaktadır.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: List.generate(qrAdListe.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: CizgiliCerceve(
              golge: 5,
              child: ListTile(
                leading: const Material(
                  color: Colors.white,
                  child: Image(
                    width: 23,
                    image: AssetImage('assets/images/QRR.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                title: GestureDetector(
                  onTap: () {
                    _launchURL(Uri.parse(qrUrlListe[index]));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      qrAdListe[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                trailing: Material(
                  child: GestureDetector(
                    onTap: () {
                      _qrSil(index);
                    },
                    child: Container(
                      color: Colors.white,
                      height: 49,
                      width: 20,
                      alignment: Alignment.centerRight,
                      child: const Center(
                        child: Image(
                          height: 25,
                          image: AssetImage('assets/images/COPP.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _qrSil(int index) async {
    final prefs = await SharedPreferences.getInstance();
    qrAdListe.removeAt(index);
    qrUrlListe.removeAt(index);

    await prefs.setString('qrAd', jsonEncode(qrAdListe));
    await prefs.setString('qrUrl', jsonEncode(qrUrlListe));

    setState(() {});
  }

  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
