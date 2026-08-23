import 'package:app/Screens/anaekran_bilesenler/anaekran/anasayfa.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:app/Screens/anaekran_bilesenler/zam/zamgiris.dart';
import 'package:flutter/material.dart';

class KarsilastirAna extends StatefulWidget {
  final int sayfano;
  const KarsilastirAna({super.key, required this.sayfano});

  @override
  State<KarsilastirAna> createState() => _KarsilastirAnaState();
}

class _KarsilastirAnaState extends State<KarsilastirAna> {
  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Anasayfa(pozisyon: 0, tarihyenile: ""),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Renk.koyuMavi),

          title: const Text("Maaş Karşılaştır"),
        ),
        body: Column(
          children: [
            Expanded(child: _buildContent()),
            const RepaintBoundary(child: BannerReklamuc()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
      child: Column(
        children: [
          _buildComparisonSection(
            title:
                widget.sayfano == 1
                    ? "Zam Öncesi Ve Sonrasını Karşılaştır"
                    : widget.sayfano == 2
                    ? "Farklı İki Maaş Karşılaştır"
                    : "Ülke Para Birimleri İle Karşılaştır",
            description:
                widget.sayfano == 1
                    ? "Bu ekranda, zam öncesi ve zam sonrası maaşınızı karşılaştırabilirsiniz. Zam oranını girerek, brüt ve net maaşınızın nasıl değiştiğini görebilir, zamın bütçenize etkisini analiz edebilirsiniz. Bu sayede, zam tekliflerini veya maaş artışlarını daha net bir şekilde değerlendirebilirsiniz."
                    : widget.sayfano == 2
                    ? "Bu ekran, iki farklı maaş teklifini veya mevcut maaşınız ile yeni bir teklifi karşılaştırmanızı sağlar. Brüt ve net maaş değerlerini girerek, hangisinin sizin için daha avantajlı olduğunu kolayca görebilirsiniz. Bu karşılaştırma, iş değişikliği veya maaş görüşmelerinde size rehberlik edecektir."
                    : "Bu ekran, farklı ülke para birimleri arasında maaş karşılaştırması yapmanızı sağlar. Maaşınızı yerel para biriminizden başka bir para birimine çevirerek, uluslararası iş tekliflerini veya yurtdışındaki yaşam maliyetlerini daha iyi anlayabilirsiniz. Bu sayede, küresel kariyer fırsatlarını daha bilinçli bir şekilde değerlendirebilirsiniz.",
            buttonText:
                widget.sayfano == 1
                    ? "Zam Öncesi Ve Sonrasını Karşılaştır"
                    : widget.sayfano == 2
                    ? "Farklı İki Maaş Karşılaştır"
                    : "Ülke Para Birimleri İle Karşılaştır",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ZamGiris(
                        id: 3,
                        grafikid:
                            widget.sayfano == 1
                                ? 1
                                : widget.sayfano == 2
                                ? 2
                                : 4,
                        sayfa: widget.sayfano,
                      ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildComparisonSection({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Dekor.butonText_18_500mavi,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 20),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: Dekor.butonText_16_400siyah,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: RepaintBoundary(child: YerelReklamuc()),
        ),
        GestureDetector(onTap: onTap, child: Renk.buton(buttonText, 50)),
      ],
    );
  }
}
