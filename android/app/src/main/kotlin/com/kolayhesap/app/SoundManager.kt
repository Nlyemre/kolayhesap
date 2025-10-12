package com.kolayhesap.app

import android.media.AudioFormat
import android.media.AudioTrack
import android.os.Process
import kotlin.math.PI
import kotlin.math.sin

class SoundManager(private val sampleRate: Int = 44100) {
    private var audioTrack: AudioTrack? = null
    @Volatile private var isPlaying = false
    @Volatile private var currentFrequency = 440 // Hz (A4 nota)
    @Volatile private var currentVolume = 0.5f   // 0.0 - 1.0 arası
    private var wavePhase = 0.0

    // 16-bit PCM için maksimum genlik (Short.MAX_VALUE)
    private val maxAmplitude = 32767 

    // Optimizasyon: Önbellek için sabitler
    private val twoPi = 2.0 * PI
    private val bufferSize = sampleRate / 10 // 100ms'lik buffer (performans dengesi)

    fun playSound(frequency: Int, volume: Float) {
        currentFrequency = frequency.coerceIn(20, 15000)
        currentVolume = volume.coerceIn(0f, 1f)

        if (isPlaying) return

        audioTrack = AudioTrack.Builder()
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(sampleRate)
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setBufferSizeInBytes(bufferSize * 2) // 16-bit = 2 byte
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()

        isPlaying = true
        audioTrack?.play()

        Thread(Runnable { // Düzeltme: Runnable kullanarak thread oluştur
            Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_AUDIO)
            val buffer = ShortArray(bufferSize)
            while (isPlaying) {
                val phaseIncrement = twoPi * currentFrequency / sampleRate
                val volumeFactor = currentVolume * maxAmplitude

                for (i in buffer.indices) {
                    buffer[i] = (sin(wavePhase) * volumeFactor).toInt().toShort()
                    wavePhase += phaseIncrement
                    if (wavePhase > twoPi) wavePhase -= twoPi
                }
                audioTrack?.write(buffer, 0, buffer.size)
            }
        }).apply {
            priority = Thread.MAX_PRIORITY // Düzeltme: Thread önceliği bu şekilde ayarlanır
            start() // Düzeltme: Thread'i başlat
        }
    }

    fun updateFrequency(newFrequency: Int) {
        currentFrequency = newFrequency.coerceIn(20, 15000)
    }

    fun updateVolume(newVolume: Float) {
        currentVolume = newVolume.coerceIn(0f, 1f)
    }

    fun stopSound() {
        isPlaying = false
        audioTrack?.apply {
            stop()
            release()
        }
        audioTrack = null
    }
}