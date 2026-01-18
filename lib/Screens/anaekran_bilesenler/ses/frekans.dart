import 'dart:async';
import 'dart:math' as math;

import 'package:app/Screens/anaekran_bilesenler/reklam/bannerreklam_3.dart';
import 'package:app/Screens/anaekran_bilesenler/reklam/yerelreklam_1.dart';
import 'package:app/Screens/anaekran_bilesenler/ses/butonlar.dart';
import 'package:app/Screens/anaekran_bilesenler/ses/degerayarlar.dart';
import 'package:app/Screens/anaekran_bilesenler/ses/fovorilistesi.dart';
import 'package:app/Screens/anaekran_bilesenler/ses/frekansgrafik.dart';
import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class Frekans extends StatefulWidget {
  const Frekans({super.key});

  @override
  State<Frekans> createState() => _FrekansState();
}

class _FrekansState extends State<Frekans> with TickerProviderStateMixin {
  static const soundChannel = MethodChannel('com.kolayhesap.app/sound');
  final ValueNotifier<double> _wavePhase = ValueNotifier(0.0);
  // Favori listesi
  final List<Map<String, dynamic>> _favorites = [];
  final TextEditingController _favoriteTitleController =
      TextEditingController();

  double frequency = 440.0;
  double volume = 50.0;
  int duration = 10;
  Timer? _durationDebounceTimer;
  Timer? _frequencyUpdateTimer;
  Timer? _volumeUpdateTimer;
  late final Ticker _ticker;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      _wavePhase.value += 0.1;
      if (_wavePhase.value > 2 * math.pi) {
        _wavePhase.value -= 2 * math.pi;
      }
    })..start();
  }

  @override
  void dispose() {
    _wavePhase.dispose();
    _ticker.dispose();
    _durationDebounceTimer?.cancel();
    _frequencyUpdateTimer?.cancel();
    _volumeUpdateTimer?.cancel();
    _volumeUpdateTimer = null;
    _favoriteTitleController.dispose();
    super.dispose();
  }

  void _frekansDegisti(double newFrequency) {
    setState(() => frequency = newFrequency);
    _frequencyUpdateTimer?.cancel();
    _frequencyUpdateTimer = Timer(const Duration(milliseconds: 100), () {
      if (_isPlaying && mounted) {
        soundChannel.invokeMethod('updateFrequency', {
          'frequency': newFrequency.toInt(),
        });
      }
    });
  }

  void _sesDegisti(double newVolume) {
    setState(() => volume = newVolume);
    _volumeUpdateTimer?.cancel();
    _volumeUpdateTimer = Timer(const Duration(milliseconds: 100), () {
      if (_isPlaying && mounted) {
        soundChannel.invokeMethod('updateVolume', {
          'volume': (newVolume / 100.0).clamp(0.0, 1.0),
        });
      }
    });
  }

  void _sureDegisti(int newDuration) {
    setState(() => duration = newDuration);
  }

  double _frekansKaydir(double sliderValue) {
    final minLog = math.log(20);
    final maxLog = math.log(15000);
    final scale = (maxLog - minLog) / 1000;
    return math.exp(minLog + sliderValue * scale);
  }

  double _frekansKaydirDeger(double frequency) {
    final minLog = math.log(20);
    final maxLog = math.log(15000);
    final scale = (maxLog - minLog) / 1000;
    return (math.log(frequency) - minLog) / scale;
  }

  void frekansiArttir() {
    if (!mounted) return;
    setState(() {
      frequency = (frequency + 1).clamp(20, 15000);
    });
  }

  void frekansiAzalt() {
    if (!mounted) return;
    setState(() {
      frequency = (frequency - 1).clamp(20, 15000);
    });
  }

  void _sesiArttir() {
    if (!mounted) return;
    setState(() {
      volume = (volume + 1).clamp(0, 100);
    });
  }

  void _sesiAzalt() {
    if (!mounted) return;
    setState(() {
      volume = (volume - 1).clamp(0, 100);
    });
  }

  void _sureyiArttir() {
    if (!mounted) return;
    setState(() {
      duration = (duration + 1).clamp(1, 60);
    });
  }

  void _sureyiAzalt() {
    if (!mounted) return;
    setState(() {
      duration = (duration - 1).clamp(1, 60);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Renk.pastelKoyuMavi),

        title: const Text("Frekans"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  FrekansGrafik(
                    frequency: frequency / 1000,
                    isPlaying: _isPlaying,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: SizedBox(
                      height: 35,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.star_border, size: 20),
                              label: const Text(
                                'FAVORİ EKLE',
                                style: TextStyle(fontSize: 13),
                              ),
                              onPressed: _showAddFavoriteDialog,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.list, size: 20),
                              label: const Text(
                                'FAVORİ LİSTEM',
                                style: TextStyle(fontSize: 13),
                              ),
                              onPressed: _openFavoritesPage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FrekansControls(
                    key: const ValueKey('frekans-controls'),
                    frequency: frequency,
                    volume: volume,
                    duration: duration,
                    isPlaying: _isPlaying,
                    wavePhase: _wavePhase,
                    frekansKaydirDeger: _frekansKaydirDeger,
                    frekansKaydir: _frekansKaydir,
                    onFrequencyChanged: _frekansDegisti,
                    onVolumeChanged: _sesDegisti,
                    onDurationChanged: _sureDegisti,
                    onDecreaseFrequency: frekansiAzalt,
                    onIncreaseFrequency: frekansiArttir,
                    onDecreaseVolume: _sesiAzalt,
                    onIncreaseVolume: _sesiArttir,
                    onDecreaseDuration: _sureyiAzalt,
                    onIncreaseDuration: _sureyiArttir,
                  ),
                  IndependentPlaybackButtons(
                    frequency: frequency,
                    volume: volume,
                    duration: duration,
                    onPlayStateChanged: (isPlaying) {
                      setState(() => _isPlaying = isPlaying);
                    },
                  ),
                ],
              ),
            ),
          ),
          const RepaintBoundary(child: BannerReklamuc()),
        ],
      ),
    );
  }

  void _openFavoritesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FavoriListesi(
              favorites: _favorites,
              onFavoriteSelected: (fav) {
                setState(() {
                  frequency = fav['frequency'];
                  volume = fav['volume'];
                  duration = fav['duration'];
                });
              },
              onFavoriteDeleted: (index) {
                setState(() {
                  _favorites.removeAt(index); // Listeden öğeyi kaldır
                });
                Mesaj.altmesaj(context, 'Favori silindi', Colors.green);
              },
            ),
      ),
    );
  }

  void _showAddFavoriteDialog() {
    AcilanPencere.show(
      context: context,
      title: "Favori Ekle",
      height: 0.8,
      showAd: false,
      content: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              MetinKutusu(
                controller: _favoriteTitleController,
                labelText: 'Başlık',
                hintText: 'Örneğin: Köpek Eğitimi',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                clearButtonVisible: true,
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Renk.buton('İptal', 45),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_favoriteTitleController.text.isNotEmpty) {
                          setState(() {
                            _favorites.add({
                              'title': _favoriteTitleController.text,
                              'frequency': frequency,
                              'volume': volume,
                              'duration': duration,
                            });
                            _favoriteTitleController.clear();
                          });
                          Navigator.pop(context);
                          Mesaj.altmesaj(
                            context,
                            'Favori eklendi',
                            Colors.green,
                          );
                        }
                      },
                      child: Renk.buton('Kaydet', 45),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: _buildSettingInfo(
                  'Frekans',
                  '${frequency.toStringAsFixed(1)} Hz',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: _buildSettingInfo('Ses Seviyesi', '${volume.toInt()}%'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: _buildSettingInfo('Süre', '${duration}s'),
              ),
              const RepaintBoundary(child: YerelReklam()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Renk.pastelKoyuMavi)),
        ],
      ),
    );
  }
}
