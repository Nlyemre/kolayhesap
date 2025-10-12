import 'package:app/Screens/anaekran_bilesenler/mesai_izin/mesaihesapla.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_2.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_5.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Mesailer extends StatefulWidget {
  const Mesailer({super.key});

  @override
  State<Mesailer> createState() => _MesailerState();
}

class _MesailerState extends State<Mesailer> {
  final _mesaiHesaplama = MesaiHesaplama();
  final _scrollController = ScrollController();
  final ValueNotifier<bool> _kaydirmakonum = ValueNotifier(false);
  bool _veriYuklendi = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
    _mesaiHesaplama
        .init()
        .then((_) {
          return _mesaiHesaplama.mesaiListeCagir();
        })
        .then((_) {
          setState(() {
            _veriYuklendi = true;
          });
        });
    _scrollController.addListener(_mesailerScrollListener);
  }

  void _mesailerScrollListener() {
    if (!_kaydirmakonum.value &&
        _scrollController.position.pixels >
            (_mesaiHesaplama.mesaiMetinListe.value.length > 3
                ? 500.0
                : 250.0)) {
      _kaydirmakonum.value = true;
      _scrollController.removeListener(
        _mesailerScrollListener,
      ); // Dinleyiciyi kaldır
    }
  }

  @override
  void dispose() {
    _mesaiHesaplama.dispose();
    _scrollController.removeListener(_mesailerScrollListener);
    _scrollController.dispose();
    _kaydirmakonum.dispose();
    super.dispose();
  }

  void _geri() {
    Navigator.of(
      context,
    ).pop(_mesaiHesaplama.veriDegisti ? 'veri_degisti' : null);
  }

  void _cikti() => _mesaiHesaplama.ciktilar(context);

  @override
  Widget build(BuildContext context) {
    if (!_veriYuklendi) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        _geri();
      },
      child: Scaffold(
        appBar: CustomAppBar(onSharePressed: _cikti, onBackPressed: _geri),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: _mesaiHesaplama.selectedIndex,
                          builder: (context, selectedIndex, _) {
                            return MesaiSecenekler(
                              selectedIndex: selectedIndex,
                              onIndexChanged: (index) {
                                _mesaiHesaplama.selectedIndex.value = index;
                                _mesaiHesaplama.veriDegisti = true;
                                setState(() {});
                              },
                              saatUcretiController:
                                  _mesaiHesaplama.saatUcretiSec,
                              gunlukUcretiController:
                                  _mesaiHesaplama.gunlukUcretiSec,
                              aylikUcretiController:
                                  _mesaiHesaplama.aylikUcretiSec,
                              onUcretChanged: () {
                                _mesaiHesaplama.mesaiListeKaydet();
                                setState(() {});
                              },
                            );
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          child: RepaintBoundary(child: YerelReklambes()),
                        ),
                        MesaiDegiskenler(
                          mesaiHesaplama: _mesaiHesaplama,
                          onUpdate: () {
                            _mesaiHesaplama.mesaiListeKaydet();
                            setState(() {});
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MesaiListeBaslik(
                            secilenYil: _mesaiHesaplama.secilenYil,
                            secilenAy: _mesaiHesaplama.secilenAy,
                            metin: "Mesai Listesi",
                          ),
                        ),
                        ValueListenableBuilder<List<String>>(
                          valueListenable: _mesaiHesaplama.mesaiMetinListe,
                          builder: (context, mesaiList, _) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (mesaiList.isEmpty)
                                  SizedBox(
                                    height: 80,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        Text(
                                          "${MesaiHesaplama.ayListe[_mesaiHesaplama.secilenAy]} ayı için kayıtlı mesainiz bulunmamaktadır.",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => _mesaiHesaplama
                                                  .mesaiEkleDialog(
                                                    context,
                                                    onUpdate:
                                                        () => setState(() {}),
                                                    isEksik: false,
                                                  ),
                                          child: const CizgiliCerceve(
                                            golge: 5,
                                            padding: EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 8,
                                              bottom: 8,
                                            ), // İç boşluk
                                            child: Text(
                                              "Şimdi Mesai Ekle",
                                              style: TextStyle(
                                                color: Renk.koyuMavi,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  ...List.generate(
                                    mesaiList.length,
                                    (index) => MesaiItem(
                                      mesaiHesaplama: _mesaiHesaplama,
                                      index: index,
                                      onUpdate: () => setState(() {}),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 10),
                          child: MesaiListeBaslik(
                            secilenYil: _mesaiHesaplama.secilenYil,
                            secilenAy: _mesaiHesaplama.secilenAy,
                            metin: "Mesai Toplamı",
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _mesaiHesaplama.selectedIndex,
                          builder: (context, selectedIndex, _) {
                            return MesaiToplamKartlar(
                              selectedIndex: _mesaiHesaplama.selectedIndex,
                              toplamMesai: _mesaiHesaplama.toplamMesai.text,
                              brutMesai: _mesaiHesaplama.brutMesai.text,
                              netMesai: _mesaiHesaplama.netMesai.text,
                              calisanTipi: _mesaiHesaplama.calisanTipi,
                            );
                          },
                        ),

                        ValueListenableBuilder<bool>(
                          valueListenable: _kaydirmakonum,
                          builder: (context, kaydirma, _) {
                            return kaydirma
                                ? const Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: RepaintBoundary(
                                    child: YerelReklamuc(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: MesaiListeBaslik(
                            secilenYil: 0,
                            secilenAy: 0,
                            metin: "Sayfanın Temel Özellikleri",
                          ),
                        ),
                        const MesaiBilgilendirme(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                const RepaintBoundary(child: BannerReklamiki()),
              ],
            ),
            Positioned(
              right: 14,
              bottom: 80,
              child: Column(
                children: [
                  Container(
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
                      heroTag: "Arti",
                      onPressed: () {
                        _mesaiHesaplama.mesaiEkleDialog(
                          context,
                          onUpdate: () => setState(() {}),
                          isEksik: false,
                        );
                      },
                      backgroundColor: Colors.white,
                      elevation: 5,
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: Renk.koyuMavi,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                      heroTag: "Eksi",
                      onPressed: () {
                        _mesaiHesaplama.mesaiEkleDialog(
                          context,
                          onUpdate: () => setState(() {}),
                          isEksik: true,
                        );
                      },
                      backgroundColor: Colors.white,
                      elevation: 5,
                      child: const Icon(
                        Icons.remove,
                        size: 30,
                        color: Renk.kirmizi,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSharePressed;
  final VoidCallback onBackPressed;

  const CustomAppBar({
    super.key,
    required this.onSharePressed,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: IconButton(
            onPressed: onSharePressed,
            icon: const Icon(Icons.share, size: 20.0, color: Renk.koyuMavi),
          ),
        ),
      ],
      leading: BackButton(color: Renk.koyuMavi, onPressed: onBackPressed),
      title: const Text("Mesailer"),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MesaiSecenekler extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final TextEditingController saatUcretiController;
  final TextEditingController gunlukUcretiController;
  final TextEditingController aylikUcretiController;
  final VoidCallback onUcretChanged;

  const MesaiSecenekler({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.saatUcretiController,
    required this.gunlukUcretiController,
    required this.aylikUcretiController,
    required this.onUcretChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(MesaiHesaplama.butonyazi.length, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  child: ButonlarRawChip(
                    isSelected: selectedIndex == index,
                    text: MesaiHesaplama.butonyazi[index],
                    onSelected: () {
                      onIndexChanged(index);
                      // MesaiHesaplama sınıfındaki listeleri sıfırla ve verileri yeniden yükle
                      final mesaiHesaplama =
                          context
                              .findAncestorStateOfType<_MesailerState>()!
                              ._mesaiHesaplama;
                      mesaiHesaplama.mesaiMetinListe.value = [];
                      mesaiHesaplama.mesaiSaatListe = [];
                      mesaiHesaplama.mesaiBurutListe = [];
                      mesaiHesaplama.mesaiNetListe = [];
                      mesaiHesaplama.mesaiListeCagir().then((_) {
                        // ignore: use_build_context_synchronously
                        context.findAncestorStateOfType<_MesailerState>()!
                        // ignore: invalid_use_of_protected_member
                        .setState(() {});
                      });
                    },
                    height: 40,
                  ),
                ),
              );
            }),
          ),
          selectedIndex == 0
              ? _buildSaatUcret()
              : selectedIndex == 1
              ? _buildGunlukUcret()
              : _buildAylikUcret(),
        ],
      ),
    );
  }

  Widget _buildSaatUcret() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 5, right: 5),
      child: MetinKutusu(
        controller: saatUcretiController,
        labelText: 'Saat Ücret',
        hintText: '0,00 TL',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) => onUcretChanged(),
        clearButtonVisible: true,
      ),
    );
  }

  Widget _buildGunlukUcret() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 5, right: 5),
      child: MetinKutusu(
        controller: gunlukUcretiController,
        labelText: 'Günlük Ücret',
        hintText: '0,00 TL',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) => onUcretChanged(),
        clearButtonVisible: true,
      ),
    );
  }

  Widget _buildAylikUcret() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 5, right: 5),
      child: MetinKutusu(
        controller: aylikUcretiController,
        labelText: 'Aylık Ücret',
        hintText: '0,00 TL',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) => onUcretChanged(),
        clearButtonVisible: true,
      ),
    );
  }
}

class MesaiDegiskenler extends StatelessWidget {
  final MesaiHesaplama mesaiHesaplama;
  final VoidCallback onUpdate;

  const MesaiDegiskenler({
    super.key,
    required this.mesaiHesaplama,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(left: 5, right: 15),
        childrenPadding: const EdgeInsets.only(left: 4, right: 5),
        title: Padding(
          padding: const EdgeInsets.only(left: 10, right: 30),
          child: Row(
            children: [
              const Text(
                "Daha Fazla Detay Düzenle",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              _bilgi(
                context,
                " Daha fazla detay eklemek isterseniz, yaziya tıklayarak Mesai yıl'ı, Mesai ay'ı, Çalışan tipi, Mesai %'si ve Kdv oran bilgileri güncelleyebilir, değişikliklerinizi kaydedebilirsiniz. Bu, Mesai ücretini daha doğru ve kişisel hale getirmenize yardımcı olur.",
              ),
            ],
          ),
        ),
        children: [
          _buildYilSecim(context),
          Dekor.cizgi15,
          _buildAySecim(context),
          Dekor.cizgi15,
          _buildCalisanTipi(context),
          Dekor.cizgi15,
          _buildMesai(context),
          Dekor.cizgi15,
          _buildKdvOrani(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildYilSecim(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Mesai Yıl'ı",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              _bilgi(
                context,
                " Mesai kayıtlarınızı doğru bir şekilde takip edebilmek için, önce mesailerin ait olduğu yılı seçin. Yıl seçimi, mesai hesaplamalarının doğru yapılmasını sağlar ve geçmiş yıllardaki verilerinizi kolayca incelemenize yardımcı olur.",
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  if (mesaiHesaplama.secilenYil > 2024) {
                    mesaiHesaplama.secilenYil--;
                    mesaiHesaplama.mesaiListeCagir().then((_) => onUpdate());
                  }
                },
              ),
              SizedBox(
                width: 60,
                child: Text(
                  mesaiHesaplama.secilenYil.toString(),
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
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  if (mesaiHesaplama.secilenYil < 2035) {
                    mesaiHesaplama.secilenYil++;
                    mesaiHesaplama.mesaiListeCagir().then((_) => onUpdate());
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAySecim(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Mesai Ay'ı",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              _bilgi(
                context,
                " Mesai kayıtlarınızı doğru bir şekilde takip edebilmek için, önce mesailerin ait olduğu ay'ı seçin. Ay seçimi, mesai hesaplamalarının doğru yapılmasını sağlar ve geçmiş aylardaki verilerinizi kolayca incelemenize yardımcı olur.",
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  if (mesaiHesaplama.secilenAy > 1) {
                    mesaiHesaplama.secilenAy--;
                    mesaiHesaplama.mesaiListeCagir().then((_) => onUpdate());
                  }
                },
              ),
              SizedBox(
                width: 60,
                child: Text(
                  MesaiHesaplama.ayListe[mesaiHesaplama.secilenAy],
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
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  if (mesaiHesaplama.secilenAy <
                      MesaiHesaplama.ayListe.length - 1) {
                    mesaiHesaplama.secilenAy++;
                    mesaiHesaplama.mesaiListeCagir().then((_) => onUpdate());
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalisanTipi(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Çalışan Tipi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              _bilgi(
                context,
                " Emekli misiniz yoksa normal çalışan mı? Emekliler için sigorta kesintisi %7.5, normal çalışanlar için ise %15 olarak hesaplanacaktır.Eger SGK yok seçerseniz kesinti %0 olarak uygulanacaktır. Bu seçim, doğru kesinti oranlarının uygulanmasını sağlar.",
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  mesaiHesaplama.calisanTipi =
                      mesaiHesaplama.calisanTipi == 'Emekli'
                          ? 'Normal'
                          : mesaiHesaplama.calisanTipi == 'Normal'
                          ? 'SGK Yok'
                          : 'Emekli';
                  mesaiHesaplama.mesaiListeKaydet();
                  onUpdate();
                },
              ),
              SizedBox(
                width: 60,
                child: Text(
                  mesaiHesaplama.calisanTipi,
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
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  mesaiHesaplama.calisanTipi =
                      mesaiHesaplama.calisanTipi == 'Normal'
                          ? 'Emekli'
                          : mesaiHesaplama.calisanTipi == 'Emekli'
                          ? 'SGK Yok'
                          : 'Normal';
                  mesaiHesaplama.mesaiListeKaydet();
                  onUpdate();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMesai(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Mesai %'si",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              _bilgi(
                context,
                " Seçtiğiniz yüzdeye göre mesai ücretinizin katsayısı hesaplanacaktır. Bu, mesai ödemelerinizin doğru şekilde hesaplanmasına yardımcı olur.",
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  if (mesaiHesaplama.mesaiSayi > 0) {
                    mesaiHesaplama.mesaiSayi--;
                    mesaiHesaplama.mesaiSec.text =
                        MesaiHesaplama.mesaiListe[mesaiHesaplama.mesaiSayi];
                    mesaiHesaplama.mesaiListeKaydet();
                    onUpdate();
                  }
                },
              ),
              SizedBox(
                width: 60,
                child: Text(
                  mesaiHesaplama.mesaiSec.text,
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
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  if (mesaiHesaplama.mesaiSayi <
                      MesaiHesaplama.mesaiListe.length - 1) {
                    mesaiHesaplama.mesaiSayi++;
                    mesaiHesaplama.mesaiSec.text =
                        MesaiHesaplama.mesaiListe[mesaiHesaplama.mesaiSayi];
                    mesaiHesaplama.mesaiListeKaydet();
                    onUpdate();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKdvOrani(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                "Vergi Oranı",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              _bilgi(
                context,
                " Seçtiğiniz yüzdeye göre mesai ücretinizden Kdv vergi kesintisi yapılacaktır. Bu, mesai ödemelerinizin doğru şekilde hesaplanmasına ve vergi kesintilerinin uygulanmasına yardımcı olur.",
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  if (mesaiHesaplama.kdvSayi > 0) {
                    mesaiHesaplama.kdvSayi--;
                    mesaiHesaplama.kdvSec.text =
                        MesaiHesaplama.kdvListe[mesaiHesaplama.kdvSayi];
                    mesaiHesaplama.mesaiListeKaydet();
                    onUpdate();
                  }
                },
              ),
              SizedBox(
                width: 60,
                child: Text(
                  mesaiHesaplama.kdvSec.text,
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
                  color: Renk.koyuMavi,
                ),
                onPressed: () {
                  if (mesaiHesaplama.kdvSayi <
                      MesaiHesaplama.kdvListe.length - 1) {
                    mesaiHesaplama.kdvSayi++;
                    mesaiHesaplama.kdvSec.text =
                        MesaiHesaplama.kdvListe[mesaiHesaplama.kdvSayi];
                    mesaiHesaplama.mesaiListeKaydet();
                    onUpdate();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bilgi(BuildContext context, String yazi) {
    return GestureDetector(
      onTap: () {
        BilgiDialog.showCustomDialog(
          context: context,
          title: 'Bilgilendirme',
          content: yazi,
          buttonText: 'Kapat',
        );
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 10, right: 5),
        child: Icon(Icons.info_outline, size: 18, color: Renk.koyuMavi),
      ),
    );
  }
}

class MesaiItem extends StatelessWidget {
  final MesaiHesaplama mesaiHesaplama;
  final int index;
  final VoidCallback onUpdate;

  const MesaiItem({
    super.key,
    required this.mesaiHesaplama,
    required this.index,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: mesaiHesaplama.secilenIndex,
      builder: (context, selectedIndex, _) {
        final isSelected = selectedIndex == index;
        final bolumler = mesaiHesaplama.mesaiMetinListe.value[index].split(' ');
        final tarihh = bolumler[1];
        final yuzde = bolumler[bolumler.length - 2];
        final isEksik =
            mesaiHesaplama.mesaiSaatListe[index] < 0; // Eksik mesai kontrolü
        return GestureDetector(
          onTap: () {
            mesaiHesaplama.secilenIndex.value = isSelected ? -1 : index;
          },
          child: Stack(
            children: [
              if (isSelected)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildEditButton(context),
                        _buildDeleteButton(context),
                      ],
                    ),
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(
                  isSelected ? -135 : 0,
                  0,
                  0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: CizgiliCerceve(
                    golge: 5,
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Tarih: $tarihh",
                                          style: Dekor.butonText_11_400siyah,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Mesai % $yuzde",
                                          style: Dekor.butonText_11_400siyah,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Düzenle",
                                          style: TextStyle(
                                            color: Renk.koyuMavi,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          " / ",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "Sil",
                                          style: TextStyle(
                                            color: Renk.kirmizi,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Renk.cita,
                              height: 15,
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildColumn(
                                  mesaiHesaplama.selectedIndex.value == 0
                                      ? "Mesai Saat"
                                      : "Mesai Gün",
                                  mesaiHesaplama.mesaiSaatListe[index]
                                      .toString(),
                                  isEksik,
                                ),
                                const SizedBox(
                                  width: 1,
                                  height: 40,
                                  child: VerticalDivider(color: Renk.cita),
                                ),
                                _buildColumn(
                                  "Mesai Brüt",
                                  NumberFormat("#,##0.00", "tr_TR").format(
                                    mesaiHesaplama.mesaiBurutListe[index],
                                  ),
                                  isEksik,
                                ),
                                const SizedBox(
                                  width: 1,
                                  height: 40,
                                  child: VerticalDivider(color: Renk.cita),
                                ),
                                _buildColumn(
                                  "Mesai Net",
                                  NumberFormat(
                                    "#,##0.00",
                                    "tr_TR",
                                  ).format(mesaiHesaplama.mesaiNetListe[index]),
                                  isEksik,
                                ),
                              ],
                            ),
                            // Notu yalnızca geçerliyse göster
                            if (mesaiHesaplama.mesaiNotListe.length > index &&
                                mesaiHesaplama.mesaiNotListe[index].isNotEmpty)
                              Column(
                                children: [
                                  const Divider(
                                    color: Renk.cita,
                                    height: 15,
                                    thickness: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 5,
                                      bottom: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Not: ${mesaiHesaplama.mesaiNotListe[index]}",
                                          style: Dekor.butonText_11_400siyah,
                                        ),
                                      ],
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await mesaiHesaplama.duzenleMesaiDialog(
          context,
          index,
          onUpdate: onUpdate,
        );
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: Renk.gradient,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: SizedBox(
            width: 60,
            child: Center(
              child: Icon(Icons.edit, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Mesaj.altmesaj(
          context,
          "${mesaiHesaplama.mesaiSaatListe[index]} Mesai Kaldırıldı",
          Colors.green,
        );
        mesaiHesaplama.listeyiGuncelle(islem: "sil", index: index);
        onUpdate();
      },
      child: const Padding(
        padding: EdgeInsets.only(bottom: 5, top: 5, right: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.red],
              begin: Alignment(1.0, -1.0),
              end: Alignment(1.0, 1.0),
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: SizedBox(
            width: 60,
            child: Center(
              child: Icon(Icons.delete, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(String title, String value, bool isEksik) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color.fromARGB(255, 29, 84, 147),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isEksik ? Renk.kirmizi : Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class MesaiToplamKartlar extends StatelessWidget {
  final ValueNotifier<int> selectedIndex;
  final String toplamMesai;
  final String brutMesai;
  final String netMesai;
  final String calisanTipi;

  const MesaiToplamKartlar({
    super.key,
    required this.selectedIndex,
    required this.toplamMesai,
    required this.brutMesai,
    required this.netMesai,
    required this.calisanTipi,
  });

  @override
  Widget build(BuildContext context) {
    final double brutsayi = double.tryParse(brutMesai) ?? 0.0;
    final double netsayi = double.tryParse(netMesai) ?? 0.0;
    final kesintiler = brutsayi - netsayi;
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, index, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              index == 0
                  ? Yansatirikili.satir(
                    "Toplam Mesai Saat",
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.tryParse(toplamMesai))} ST',
                    Renk.koyuMavi,
                  )
                  : Yansatirikili.satir(
                    "Toplam Mesai Gün",
                    '${NumberFormat("#,##0.00", "tr_TR").format(double.tryParse(toplamMesai))} GN',
                    Renk.koyuMavi,
                  ),
              Dekor.cizgi15,
              Yansatirikili.satir(
                'Toplam Mesai Brüt',
                '${NumberFormat("#,##0.00", "tr_TR").format(double.tryParse(brutMesai))} TL',
                Renk.koyuMavi,
              ),
              Dekor.cizgi15,
              Yansatirikili.satir(
                'Toplam Kesintiler',
                '${NumberFormat("#,##0.00", "tr_TR").format(double.tryParse(kesintiler.abs().toString()))} TL',
                Renk.kirmizi,
              ),
              Dekor.cizgi15,
              Yansatirikili.satir(
                'Toplam Mesai Net',
                '${NumberFormat("#,##0.00", "tr_TR").format(double.tryParse(netMesai))} TL',
                Renk.koyuMavi,
              ),
            ],
          ),
        );
      },
    );
  }
}

class MesaiListeBaslik extends StatelessWidget {
  final int secilenYil;
  final int secilenAy;
  final String metin;

  const MesaiListeBaslik({
    super.key,
    required this.secilenYil,
    required this.secilenAy,
    required this.metin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      color: Renk.koyuMavi.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          secilenYil == 0
              ? metin
              : "$secilenYil ${MesaiHesaplama.ayListe[secilenAy]} $metin",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Renk.koyuMavi,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class MesaiSecimDialog extends StatelessWidget {
  final TextEditingController tarihController;
  final TextEditingController notController;
  final List<String> items;
  final ValueChanged<int> onSelected;
  final VoidCallback? onUpdate;

  const MesaiSecimDialog({
    super.key,
    required this.tarihController,
    required this.notController,
    required this.items,
    required this.onSelected,
    this.onUpdate,
  });

  void _tarihSec(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
    );
    if (pickedDate != null) {
      tarihController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _tarihSec(context),
            child: AbsorbPointer(
              child: TextField(
                controller: tarihController,
                decoration: const InputDecoration(
                  labelText: 'Tarih',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notController,
            decoration: const InputDecoration(
              labelText: 'Not Ekle',
              hintText: 'Mesai detaylarını yazın',
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 5),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder:
                  (context, index) =>
                      const Divider(color: Renk.cita, height: 5, thickness: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(index);
                    onUpdate?.call();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MesaiBilgilendirme extends StatelessWidget {
  const MesaiBilgilendirme({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            'Mesai Hesaplama ve Kaydetme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.koyuMavi,
            ),
          ),
          Text(
            'Kullanıcılar, mesai saatlerini, günlerini veya aylık ücretlerini girerek mesai ücretlerini hesaplayabilirler.\n\n'
            'Hesaplanan mesai ücretleri, brüt ve net olarak ayrı ayrı gösterilir.\n\n'
            'Kullanıcılar, hesapladıkları mesaileri kaydedebilir ve daha sonra bu kayıtları görüntüleyebilir veya düzenleyebilirler.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Geçmiş Kayıtları Görüntüleme ve Düzenleme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.koyuMavi,
            ),
          ),
          Text(
            'Kullanıcılar, geçmiş aylara ait mesai kayıtlarını görüntüleyebilir ve bu kayıtlar üzerinde değişiklik yapabilirler.\n\n'
            'Kayıtlar, kullanıcıların seçtiği ay ve yıla göre filtrelenebilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Çalışan Tipi ve Vergi Oranları',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.koyuMavi,
            ),
          ),
          Text(
            'Kullanıcılar, çalışan tipini (normal veya emekli) seçebilir ve bu seçime göre SGK kesintisi oranı otomatik olarak ayarlanır.\n\n'
            'Ayrıca, kullanıcılar mesai ücretine uygulanacak KDV oranını da belirleyebilirler.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Veri Kaydetme ve Paylaşma',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.koyuMavi,
            ),
          ),
          Text(
            'Kullanıcının girdiği veriler ve mesai kayıtlarını, Yerel bellek kullanılarak cihazda saklanır. Bu sayede, kullanıcı uygulamayı kapatsa bile veriler kaybolmaz ve daha sonra tekrar erişilebilir.\n\n'
            'Ayrıca, kullanıcı mesai kayıtlarını diğer uygulamalarla paylaşabilir. Örneğin, mesai kayıtlarını bir mesajlaşma uygulaması üzerinden paylaşabilir veya e-posta ile gönderebilir.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Kullanıcı Dostu Arayüz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.koyuMavi,
            ),
          ),
          Text(
            'Sayfa, kullanıcıların kolayca anlayabileceği ve kullanabileceği bir arayüz sunar.\n\n'
            'Mesai ekleme, düzenleme ve silme işlemleri kullanıcı dostu bir şekilde tasarlanmıştır.',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 20),
          Text(
            'Bilgilendirme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Renk.koyuMavi,
            ),
          ),
          Text(
            'Hesaplama ve hesaplatma için bu uygulamadaki veriler yasal olarak bağlayıcı değildir. Kullanıcı bu uygulamada verilen bilgileri hesaplatma sonuçlarını kendi hesaplamalarına veya kullanımlarına temel almadan önce doğrulatması gerekir. Bu sebepten dolayı bu uygulamada verilen bilgilerin ve elde edilen hesaplatma sonuçlarının doğruluna ilişkin olarak Kolay Hesap Uygulaması sorumluluk veya garanti üstlenmez.',
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
