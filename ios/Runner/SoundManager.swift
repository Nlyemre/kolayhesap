import AVFoundation

class SoundManager {
    private var engine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var frequency: Double = 440.0
    private var volume: Float = 0.5
    private let sampleRate: Double = 44100.0
    private var phase: Double = 0.0

    func playSound(frequency: Int, volume: Float) {
        print("Ses çalmaya başlandı. Frekans: \(frequency) Hz, Ses Seviyesi: \(volume)")

        stopSound()
        print("Önceki ses durduruldu.")

        self.frequency = Double(frequency)
        self.volume = volume.clamped(to: 0.0...1.0)
        print("Frekans ve ses seviyesi güncellendi.")

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        print("Ses formatı ayarlandı.")

        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }

            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let phaseIncrement = 2.0 * Double.pi * self.frequency / self.sampleRate

            for frame in 0..<Int(frameCount) {
                let sample = sin(self.phase) * Double(self.volume)
                self.phase += phaseIncrement
                if self.phase > 2.0 * Double.pi {
                    self.phase -= 2.0 * Double.pi
                }

                for buffer in ablPointer {
                    let floatBuffer = buffer.mData?.assumingMemoryBound(to: Float.self)
                    floatBuffer?[frame] = Float(sample)
                }
            }

            return noErr
        }

        engine = AVAudioEngine()
        guard let engine = engine, let sourceNode = sourceNode else {
            print("Ses motoru başlatılamadı. Hata!")
            return
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        print("Ses motoru başlatıldı ve bağlantılar yapıldı.")

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            print("Ses motoru başarıyla çalışmaya başladı.")
        } catch {
            print("Ses motoru başlatılamadı: \(error.localizedDescription)")
        }
    }

    func updateFrequency(newFrequency: Int) {
        print("Frekans güncelleniyor. Yeni Frekans: \(newFrequency) Hz")
        frequency = Double(newFrequency)
        print("Frekans başarıyla güncellendi.")
    }

    func updateVolume(newVolume: Float) {
        print("Ses seviyesi güncelleniyor. Yeni Ses Seviyesi: \(newVolume)")
        volume = newVolume.clamped(to: 0.0...1.0)
        print("Ses seviyesi başarıyla güncellendi.")
    }

    func stopSound() {
        print("Ses durduruluyor...")
        engine?.stop()
        engine = nil
        sourceNode = nil
        phase = 0.0
        print("Ses durduruldu ve kaynaklar serbest bırakıldı.")

        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("Audio session devre dışı bırakıldı.")
        } catch {
            print("Audio session devre dışı bırakılamadı: \(error.localizedDescription)")
        }
    }
}

// Comparable extension ekleniyor
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
