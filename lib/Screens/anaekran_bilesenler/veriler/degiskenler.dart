import 'package:app/Screens/anaekran_bilesenler/abonelik/abonelik_satis.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_6.dart';
import 'package:app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';

class Renk {
  // Sabit renkler
  static const Color pastelKoyuMavi = Color(0xFF3F74AE); // 1d5593 koyu mavi
  static const Color pastelAcikMavi = Color(0xFF7FDADB); // 26cacb açık mavi
  static const Color kirmizi = Color.fromARGB(202, 200, 0, 0);
  static const Color acikgri = Color.fromARGB(255, 250, 250, 250);
  static const Color cita = Color.fromARGB(113, 96, 125, 139);
  static final Color pastelMavi = Color.lerp(Colors.blue, Colors.white, 0.9)!;
  static final Color pastelYesil = Color.lerp(Colors.green, Colors.white, 0.9)!;
  static final Color pastelKirmizi =
      Color.lerp(Colors.red, Colors.white, 0.92)!;
  static const LinearGradient gradient = LinearGradient(
    colors: [pastelAcikMavi, pastelKoyuMavi],
    begin: Alignment(1.0, -1.0),
    end: Alignment(1.0, 1.0),
  );

  // Buton widget'ı
  static Widget buton(String ad, double yukseklik) {
    return Container(
      height: yukseklik,
      decoration: const BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          ad,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Mesaj {
  static void altmesaj(BuildContext context, String mesaj, Color renk) {
    try {
      // Context hala geçerli mi kontrol et
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mesaj),
            backgroundColor: renk,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        );
      }
    } catch (e) {
      // Hata olursa sessizce devam et
      if (kDebugMode) {
        print("Snackbar gösterilemedi: $e");
      }
    }
  }
}

class MetinKutusu extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final bool clearButtonVisible;

  const MetinKutusu({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    required this.onChanged,
    this.clearButtonVisible = true,
  });

  @override
  State<MetinKutusu> createState() => _MetinKutusuState();
}

class _MetinKutusuState extends State<MetinKutusu> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 50,
          child: TextField(
            textAlignVertical: TextAlignVertical.bottom,
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
            ),
            keyboardType: widget.keyboardType,
            onTap: () {
              if (widget.controller.text.trim() == "0.0" ||
                  widget.controller.text.trim() == "0") {
                // Kullanıcının görebilmesi için controller değerini boş yap
                widget.controller.clear();
              }
            },
            onChanged: (value) {
              if (value.contains(',')) {
                String formattedInput = value.replaceAll(',', '.');
                widget.controller.value = TextEditingValue(
                  text: formattedInput,
                  selection: TextSelection.collapsed(
                    offset: formattedInput.length,
                  ),
                );
              }
              widget.onChanged(value);
            },
          ),
        ),
        if (widget.clearButtonVisible && widget.controller.text.isNotEmpty)
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.clear,
                size: 16,
                color: Color.fromARGB(255, 98, 98, 98),
              ),
              onPressed: () {
                widget.controller.clear();
              },
            ),
          ),
      ],
    );
  }
}

class Kartt {
  static Widget kartHazir({
    required String baslik,
    required String deger,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: GestureDetector(
          onTap: onTap,
          child: CizgiliCerceve(
            golge: 5,
            backgroundColor: Renk.acikgri,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text(
                    baslik,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deger,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Renk.pastelKoyuMavi,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Yansatirikili {
  static Widget satir(String title, String value, Color renk) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: renk,
            ),
          ),
        ],
      ),
    );
  }
}

class ButonlarRawChip extends StatelessWidget {
  final bool isSelected;
  final String text;
  final VoidCallback onSelected;
  final double? height;
  final double? fontSize;
  final int? maxLines;
  final Gradient? gradient;
  final Color? unselectedColor;
  final Color? borderColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final BorderRadius? borderRadius;

  const ButonlarRawChip({
    super.key,
    required this.isSelected,
    required this.text,
    required this.onSelected,
    this.height = 35,
    this.fontSize = 13,
    this.maxLines = 1,
    this.gradient,
    this.unselectedColor = Colors.white,
    this.borderColor,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return RawChip(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(5.0)),
        side: BorderSide(
          color: isSelected ? Colors.transparent : borderColor ?? Renk.cita,
          width: 1.0,
        ),
      ),
      backgroundColor: Colors.transparent,
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      label: Ink(
        decoration: BoxDecoration(
          gradient: isSelected ? gradient ?? Renk.gradient : null,
          color: !isSelected ? unselectedColor : null,
          borderRadius:
              borderRadius ?? const BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Container(
          height: height,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color:
                  isSelected
                      ? selectedTextColor
                      : unselectedTextColor ?? Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
            ),
            textScaler: TextScaler.noScaling,
            textAlign: TextAlign.center,
            maxLines: maxLines,
          ),
        ),
      ),
    );
  }
}

class AcilanPencere extends StatefulWidget {
  final String title;
  final Widget content;
  final double height;
  final bool showAd;
  final Widget adWidget;

  const AcilanPencere({
    super.key,
    required this.title,
    required this.content,
    this.height = 0.8,
    this.showAd = true,
    this.adWidget = const YerelReklamalti(),
  });

  @override
  State<AcilanPencere> createState() => _AcilanPencereState();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    double height = 0.9,
    bool showAd = true,
    Widget adWidget = const YerelReklamalti(),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: const Color.fromARGB(126, 0, 0, 0),
      useSafeArea: true,
      builder:
          (context) => AcilanPencere(
            title: title,
            content: content,
            height: height,
            showAd: showAd,
            adWidget: adWidget,
          ),
    );
  }
}

class _AcilanPencereState extends State<AcilanPencere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuart,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _close();
      },
      child: FadeTransition(
        opacity: _curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_curvedAnimation),
          child: Container(
            height: MediaQuery.of(context).size.height * widget.height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Renk.pastelKoyuMavi,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _close,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Divider(color: Color(0xFFE0E0E0), thickness: 1),
                      ),
                    ],
                  ),
                ),
                Expanded(child: widget.content),
                if (widget.showAd)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: widget.adWidget,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BilgiDialog {
  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'Kapat',
    VoidCallback? onButtonPressed,
    Color backgroundColor = Colors.white,
    Color titleColor = Renk.pastelKoyuMavi,
    Color buttonTextColor = Renk.pastelKoyuMavi,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          backgroundColor: backgroundColor,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: titleColor,
            ),
          ),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: buttonTextColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (onButtonPressed != null) {
                  onButtonPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String yesText = 'Evet',
    String noText = 'Hayır',
    Color yesButtonColor = Renk.pastelKoyuMavi,
    Color noButtonColor = Renk.pastelKoyuMavi,
    Color backgroundColor = Colors.white,
    Color titleColor = Renk.pastelKoyuMavi,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          backgroundColor: backgroundColor,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: titleColor,
            ),
          ),
          content: Text(content),
          actions: <Widget>[
            // Hayır butonu
            TextButton(
              child: Text(
                noText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: noButtonColor, // Renk.pastelKoyuMavi
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),

            // Evet butonu - KIRMIZI DEĞİL, Renk.pastelKoyuMavi
            TextButton(
              child: Text(
                yesText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: yesButtonColor, // Renk.pastelKoyuMavi
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}

class AbonelikDialog {
  static Future<void> abonegit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    await AcilanPencere.show(
      context: context,
      title: 'Bilgilendirme',
      height: 0.9,
      content: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: Renk.gradient,
              ),
              padding: const EdgeInsets.all(24),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 72,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bu Özellik Sadece Üyelere Özel',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Renk.pastelKoyuMavi,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Abonelik ile reklamsız deneyimin tadını çıkarın, '
              'özel içeriklere erişin ve tüm özellikleri sınırsız kullanın.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 28),
            const Row(
              children: [
                Icon(Icons.block, color: Renk.pastelKoyuMavi),
                SizedBox(width: 10),
                Expanded(child: Text('Tüm reklamlar kaldırılır')),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.lock_open, color: Renk.pastelKoyuMavi),
                SizedBox(width: 10),
                Expanded(child: Text('Tüm premium içeriklere erişim')),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Renk.pastelKoyuMavi),
                SizedBox(width: 10),
                Expanded(child: Text('Kesintisiz ve hızlı kullanım')),
              ],
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SatinAlmaSayfasi(),
                  ),
                );
              },
              child: Container(
                height: 55,
                decoration: const BoxDecoration(
                  gradient: Renk.gradient,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Abonelik Sayfasına Git',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> paylasimPenceresiAc({
  required BuildContext context,
  required VoidCallback paylasPDF,
  required VoidCallback paylasExcel,
  required VoidCallback paylasMetin,
}) async {
  final double ekranYuksekligi = MediaQuery.of(context).size.height;

  double oran = ekranYuksekligi < 600 ? 0.65 : 0.5;

  await AcilanPencere.show(
    context: context,
    title: 'Paylaş',
    height: oran,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PDF
        ListTile(
          title: const Text(
            'PDF Oluştur Ve Paylaş',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          onTap: () {
            if (!AboneMi.isReklamsiz) {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                // ignore: use_build_context_synchronously
                AbonelikDialog.abonegit(context);
              });
            } else {
              paylasPDF();
              Navigator.of(context).pop();
            }
          },
        ),
        Dekor.cizgi15,
        // Excel
        ListTile(
          title: const Text(
            'Excel Oluştur Ve Paylaş',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          onTap: () {
            if (!AboneMi.isReklamsiz) {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                // ignore: use_build_context_synchronously
                AbonelikDialog.abonegit(context);
              });
            } else {
              paylasExcel();
              Navigator.of(context).pop();
            }
          },
        ),
        Dekor.cizgi15,
        // Metin
        ListTile(
          title: const Text(
            'Düz Metin Oluştur Ve Paylaş',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          onTap: () {
            if (!AboneMi.isReklamsiz) {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                // ignore: use_build_context_synchronously
                AbonelikDialog.abonegit(context);
              });
            } else {
              paylasMetin();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    ),
  );
}

class CemberAna extends StatelessWidget {
  final double deger1; // Dilim değeri
  final String isim1; // Dilim ismi
  final double deger2; // Dilim değeri
  final String isim2; // Dilim ismi

  const CemberAna({
    super.key,
    required this.deger1,
    required this.isim1,
    required this.deger2,
    required this.isim2,
  });

  @override
  Widget build(BuildContext context) {
    // Örnek Veri
    final List<Cember> data = [
      Cember(
        items: [
          ChartPieItem(amount: deger1, name: isim1, color: Renk.pastelKoyuMavi),
          ChartPieItem(amount: deger2, name: isim2, color: Renk.pastelAcikMavi),
        ],
      ),
    ];

    // Katmanları Oluştur
    final chartLayers = CemberKart.fromStockDataMultiPieItemList(data);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Chart(
            layers: chartLayers, // Oluşturulan katmanlar
          ),
        ),
      ),
    );
  }
}

// Veri Modeli
class Cember {
  final List<ChartPieItem> items;

  Cember({required this.items});
}

class ChartPieItem {
  final double amount;
  final String name;
  final Color color;

  ChartPieItem({required this.amount, required this.name, required this.color});
}

class CemberKart {
  static List<ChartLayer> fromStockDataMultiPieItemList(List<Cember> items) {
    return [
      ChartGroupPieLayer(
        items:
            items
                .map(
                  (section) =>
                      section.items
                          .map(
                            (element) => ChartGroupPieDataItem(
                              amount: element.amount,
                              color: element.color,
                              label: element.name,
                            ),
                          )
                          .toList(),
                )
                .toList(),
        settings: const ChartGroupPieSettings(
          gapSweepAngle: 25,
          thickness: 20,
          angleOffset: -65.0,
          gapBetweenChartCircles: 18.0,
        ),
      ),
      ChartTooltipLayer(
        shape:
            () => ChartTooltipPieShape<ChartGroupPieDataItem>(
              onTextName: (item) => item.label,
              onTextValue: (item) => '${item.amount.toStringAsFixed(2)} TL',
              radius: 10.0,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12.0),
              nameTextStyle: const TextStyle(
                color: Color.fromARGB(255, 68, 138, 255),
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
              valueTextStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 12.0,
              ),
            ),
      ),
    ];
  }
}

// kullanılmıyor yedek
class CizgiliCerceve extends StatelessWidget {
  final Widget child;
  final double golge;
  final Color borderColor;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const CizgiliCerceve({
    super.key,
    required this.child,
    this.golge = 0,
    this.borderColor = Renk.cita,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor = Colors.white,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(width: 1.0, color: borderColor),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Renk.pastelKoyuMavi.withValues(alpha: 0.15),
            blurRadius: golge,
          ),
        ],
      ),
      child: child,
    );
  }
}

class Dekor {
  static final DateFormat tarihFormati = DateFormat('dd MMMM yyyy', 'tr_TR');
  static final NumberFormat paraFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺ ',
  );

  static const cizgi15 = Divider(
    color: Renk.cita,
    height: 15,
    thickness: 1,
    indent: 5,
    endIndent: 5,
  );
  static const cizgi25 = Divider(
    color: Renk.cita,
    height: 25,
    thickness: 1,
    indent: 5,
    endIndent: 5,
  );

  static const cizgi30 = Divider(color: Renk.cita, height: 30, thickness: 1);
  static const TextStyle butonText_12_500mavi = TextStyle(
    color: Renk.pastelKoyuMavi,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_13_500mavi = TextStyle(
    color: Renk.pastelKoyuMavi,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_14_500mavi = TextStyle(
    color: Renk.pastelKoyuMavi,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_12_500siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_13_500siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 13,
    fontWeight: FontWeight.w500,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_14_500siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 14,
    fontWeight: FontWeight.w500,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_12_400mavi = TextStyle(
    color: Renk.pastelKoyuMavi,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_13_400mavi = TextStyle(
    color: Renk.pastelKoyuMavi,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_14_400mavi = TextStyle(
    color: Renk.pastelKoyuMavi,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_12_400siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 12,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_13_400siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 13,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_14_400siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 14,
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
  );
  static const TextStyle butonText_10_500mavi = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Renk.pastelKoyuMavi,
  );
  static const TextStyle butonText_10_400siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle butonText_11_500beyaz = TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle butonText_12_500beyaz = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle butonText_11_500mavi = TextStyle(
    color: Renk.pastelKoyuMavi,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle butonText_11_500siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle butonText_17_500siyah = TextStyle(
    color: Color.fromARGB(255, 30, 30, 30),
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle butonText_18_500mavi = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Renk.pastelKoyuMavi,
  );
  static const TextStyle butonText_15_400siyah = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color.fromARGB(255, 30, 30, 30),
  );
  static const TextStyle butonText_16_400siyah = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color.fromARGB(255, 30, 30, 30),
  );
  static const TextStyle butonText_16_500mavi = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Renk.pastelKoyuMavi,
  );
  static const TextStyle butonText_15_500mavi = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Renk.pastelKoyuMavi,
  );
  static const TextStyle butonText_11_400siyah = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color.fromARGB(255, 30, 30, 30),
  );
}
