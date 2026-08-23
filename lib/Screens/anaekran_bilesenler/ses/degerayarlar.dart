import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';

class FrekansControls extends StatefulWidget {
  final double frequency;
  final double volume;
  final int duration;
  final bool isPlaying;
  final ValueNotifier<double> wavePhase;
  final double Function(double) frekansKaydirDeger;
  final double Function(double) frekansKaydir;
  final ValueChanged<double> onFrequencyChanged;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onDecreaseFrequency;
  final VoidCallback onIncreaseFrequency;
  final VoidCallback onDecreaseVolume;
  final VoidCallback onIncreaseVolume;
  final VoidCallback onDecreaseDuration;
  final VoidCallback onIncreaseDuration;

  const FrekansControls({
    super.key,
    required this.frequency,
    required this.volume,
    required this.duration,
    required this.isPlaying,
    required this.wavePhase,
    required this.frekansKaydirDeger,
    required this.frekansKaydir,
    required this.onFrequencyChanged,
    required this.onVolumeChanged,
    required this.onDurationChanged,
    required this.onDecreaseFrequency,
    required this.onIncreaseFrequency,
    required this.onDecreaseVolume,
    required this.onIncreaseVolume,
    required this.onDecreaseDuration,
    required this.onIncreaseDuration,
  });

  @override
  State<FrekansControls> createState() => _FrekansControlsState();
}

class _FrekansControlsState extends State<FrekansControls> {
  double? _tempDuration;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ayarlar(
          title: 'Frekans (${widget.frequency.toStringAsFixed(1)} Hz)',
          value: widget.frekansKaydirDeger(widget.frequency),
          min: 0,
          max: 1000,
          onChanged:
              (value) => widget.onFrequencyChanged(widget.frekansKaydir(value)),
          unit: 'Hz',
          onDecrease: widget.onDecreaseFrequency,
          onIncrease: widget.onIncreaseFrequency,
          wavePhase: widget.wavePhase,
          delayUpdate: false,
        ),
        Dekor.cizgi25,
        _ayarlar(
          title: 'Ses Seviyesi (${widget.volume.toInt()}%)',
          value: widget.volume,
          min: 0,
          max: 100,
          onChanged: widget.onVolumeChanged,
          unit: '%',
          onDecrease: widget.onDecreaseVolume,
          onIncrease: widget.onIncreaseVolume,
          wavePhase: widget.wavePhase,
          delayUpdate: false,
        ),
        Dekor.cizgi25,
        _ayarlar(
          title:
              'Çalma Süresi (${(_tempDuration ?? widget.duration).toInt()}s)',
          value: (_tempDuration ?? widget.duration).toDouble(),
          min: 1,
          max: 60,
          onChanged: (value) {
            setState(() {
              _tempDuration = value;
            });
          },
          onChangeEnd: (value) {
            widget.onDurationChanged(value.toInt());
            setState(() {
              _tempDuration = null; // tekrar ana değere dön
            });
          },
          unit: 's',
          onDecrease: () {
            widget.onDecreaseDuration();
            setState(() {
              _tempDuration = null;
            });
          },
          onIncrease: () {
            widget.onIncreaseDuration();
            setState(() {
              _tempDuration = null;
            });
          },
          wavePhase: widget.wavePhase,
          delayUpdate: true,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _ayarlar({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
    required String unit,
    VoidCallback? onDecrease,
    VoidCallback? onIncrease,
    required ValueNotifier<double> wavePhase,
    bool delayUpdate = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(title, style: const TextStyle(fontSize: 13)),
          ),
          SizedBox(
            height: 35,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.remove, size: 25),
                  onPressed: onDecrease,
                ),
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: wavePhase,
                    builder: (context, _, _) {
                      return delayUpdate
                          ? DelayedSlider(
                            value: value,
                            min: min,
                            max: max,

                            label:
                                '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}$unit',
                            onChanged: onChanged,
                            onChangeEnd: onChangeEnd!,
                          )
                          : Slider(
                            value: value,
                            min: min,
                            max: max,
                            activeColor: const Color.fromARGB(200, 29, 84, 147),
                            inactiveColor: const Color.fromARGB(
                              255,
                              215,
                              215,
                              215,
                            ),
                            thumbColor: const Color.fromARGB(200, 29, 84, 147),
                            label:
                                '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}$unit',
                            onChanged: onChanged,
                            padding: EdgeInsets.zero,
                          );
                    },
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add, size: 25),
                  onPressed: onIncrease,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${min.toInt()}$unit',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${max.toInt()}$unit',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DelayedSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;

  final String? label;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const DelayedSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,

    this.label,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  State<DelayedSlider> createState() => _DelayedSliderState();
}

class _DelayedSliderState extends State<DelayedSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(DelayedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentValue,
      min: widget.min,
      max: widget.max,

      label: widget.label,
      activeColor: const Color.fromARGB(200, 29, 84, 147),
      inactiveColor: const Color.fromARGB(255, 215, 215, 215),
      thumbColor: const Color.fromARGB(200, 29, 84, 147),
      onChanged: (value) {
        setState(() {
          _currentValue = value;
        });
        widget.onChanged(value); // Anlık değişim bildirimi
      },
      onChangeEnd: widget.onChangeEnd,
      padding: EdgeInsets.zero,
    );
  }
}
