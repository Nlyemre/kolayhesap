import 'dart:async';

import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_4.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IndependentPlaybackButtons extends StatefulWidget {
  final double frequency;
  final double volume;
  final int duration;
  final ValueChanged<bool>? onPlayStateChanged; // Yeni eklenen callback

  const IndependentPlaybackButtons({
    super.key,
    required this.frequency,
    required this.volume,
    required this.duration,
    this.onPlayStateChanged, // Yeni eklenen callback
  });

  @override
  State<IndependentPlaybackButtons> createState() =>
      _IndependentPlaybackButtonsState();
}

class _IndependentPlaybackButtonsState
    extends State<IndependentPlaybackButtons> {
  static const String _infoText = """
🎶 Frekans Gücünü Keşfedin!

Bu uygulama ile ses frekanslarını kontrol edebilir, çeşitli amaçlar için kullanabilirsiniz.

🔊 Frekans ile Yapabilecekleriniz:

• **Hayvan Eğitimi**: Frekanslar, hayvanların davranışlarını değiştirmeye yardımcı olabilir. Düşük frekanslar, sakinleştirici bir etki yaratırken, yüksek frekanslar dikkat çekici olabilir. 
    - **Köpek eğitimi**: Köpeklerinize sesli komutları öğretmek ve davranışlarını düzeltmek için frekanslı sinyaller kullanabilirsiniz.
    - **Kuş eğitimi**: Kuşların yeni seslere tepki vermesini sağlamak için farklı frekanslar ile eğitim verebilirsiniz.
    - **Kediler için rahatlatıcı frekanslar**: Kedilerin huzursuzluklarını gidermek ve onları sakinleştirmek için düşük frekanslı sesler kullanılabilir.

• **Ses Terapisi**: Farklı frekanslarla zihin sağlığını iyileştirebilir ve rahatlama sağlayabilirsiniz.
• **Konsantrasyon artırıcı frekanslar**: Odaklanmanızı artırmak için frekansları kullanarak daha verimli çalışabilirsiniz.
• **Rahatlatıcı meditasyon**: Zihninizi dinlendirmek ve gevşemek için belirli frekanslarla meditasyon yapabilirsiniz.
• **Karmaşık davranışların düzeltilmesi**: Hayvanların tekrarlayan davranışlarını düzeltmek için belirli frekanslar kullanılabilir. Örneğin, fazla havlayan köpekler için yüksek frekanslı sesler, odaklanmalarını sağlayabilir.

✨ Nasıl çalışır?

1️⃣ İstediğiniz frekansı seçin
2️⃣ Süreyi belirleyin ve sesi başlatın
3️⃣ Farklı frekanslarla deneyler yaparak hayvanlarınızın tepkilerini gözlemleyin ve en uygun frekansı bulun

"Sesin gücünü kullanarak hem kendinizin hem de hayvanlarınızın yaşam kalitesini artırın. Hadi başlayalım!"
""";
  static const soundChannel = MethodChannel('com.kolayhesap.app/sound');
  bool _isPlaying = false;
  Timer? _playbackTimer;

  @override
  void dispose() {
    _stopSound();
    _playbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSound() async {
    if (!mounted) return;

    await soundChannel.invokeMethod('playSound', {
      'frequency': widget.frequency.toInt(),
      'volume': widget.volume / 100.0,
    });
    if (!mounted) return;
    setState(() {
      _isPlaying = true;
      widget.onPlayStateChanged?.call(true);
    });

    _playbackTimer = Timer(Duration(seconds: widget.duration), () async {
      // Süre dolunca sesi durdur
      await _stopSound();
    });
  }

  Future<void> _updateFrequency(double newFrequency) async {
    if (_isPlaying && mounted) {
      await soundChannel.invokeMethod('updateFrequency', {
        'frequency': newFrequency.toInt(),
      });
    }
  }

  Future<void> _updateVolume(double newVolume) async {
    if (_isPlaying && mounted) {
      await soundChannel.invokeMethod('updateVolume', {
        'volume': newVolume / 100.0,
      });
    }
  }

  Future<void> _stopSound() async {
    await soundChannel.invokeMethod('stopSound');
    if (mounted) {
      setState(() {
        _isPlaying = false;
        widget.onPlayStateChanged?.call(false);
      });
    }
    _playbackTimer?.cancel();
  }

  @override
  void didUpdateWidget(IndependentPlaybackButtons oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isPlaying && mounted) {
      if (widget.frequency != oldWidget.frequency) {
        _updateFrequency(widget.frequency);
      }
      if (widget.volume != oldWidget.volume) {
        _updateVolume(widget.volume);
      }
      if (widget.duration != oldWidget.duration) {
        _handleDurationChange();
      }
    }
  }

  void _handleDurationChange() {
    if (!mounted) return;
    _playbackTimer?.cancel();
    _playbackTimer = Timer(Duration(seconds: widget.duration), () async {
      // Süre dolunca sesi durdur
      await _stopSound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            child: Row(
              children: [
                Expanded(
                  child: _buildButton(
                    text: 'BAŞLAT',
                    active: !_isPlaying,
                    onPressed: _isPlaying ? null : _startSound,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildButton(
                    text: 'DURDUR',
                    active: _isPlaying,
                    onPressed: _isPlaying ? _stopSound : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20, left: 5, right: 5),
          child: RepaintBoundary(child: YerelReklamdort()),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 50),
          child: Text(
            _infoText,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required bool active,
    required VoidCallback? onPressed,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient:
            active
                ? Renk.gradient
                : const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 250, 250, 250),
                    Color.fromARGB(255, 250, 250, 250),
                  ],
                  begin: Alignment(1.0, -1.0),
                  end: Alignment(1.0, 1.0),
                ),
        border: Border.all(
          color:
              active
                  ? const Color.fromARGB(0, 255, 255, 255)
                  : const Color.fromARGB(62, 96, 125, 139),
          width: 1.0,
          style: BorderStyle.solid,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          splashColor: const Color.fromARGB(80, 255, 255, 255),
          onTap: onPressed,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
