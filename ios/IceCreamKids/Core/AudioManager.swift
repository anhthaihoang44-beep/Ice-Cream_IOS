import Foundation
import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    var isMuted: Bool = false {
        didSet {
            if isMuted {
                bgmPlayer?.pause()
            } else {
                bgmPlayer?.play()
            }
        }
    }

    private init() {
        configureAudioSession()
        preloadSounds()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session configuration error: \(error)")
        }
    }

    private func preloadSounds() {
        let soundNames = [
            "sfx_pop", "sfx_click", "sfx_freeze", "sfx_pour",
            "sfx_scoop", "sfx_splash", "sfx_sprinkle", "sfx_yummy",
            "sfx_celebrate"
        ]
        for name in soundNames {
            if let url = findAudioURL(named: name, ext: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    sfxPlayers[name] = player
                } catch {
                    print("Failed to preload \(name): \(error)")
                }
            }
        }
    }

    private func findAudioURL(named name: String, ext: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Audio") {
            return url
        }
        return nil
    }

    func playBGM() {
        guard !isMuted else { return }
        if bgmPlayer == nil {
            if let url = findAudioURL(named: "bgm_happy_loop", ext: "wav") {
                do {
                    bgmPlayer = try AVAudioPlayer(contentsOf: url)
                    bgmPlayer?.numberOfLoops = -1
                    bgmPlayer?.volume = 0.55
                    bgmPlayer?.prepareToPlay()
                } catch {
                    print("BGM load error: \(error)")
                }
            }
        }
        bgmPlayer?.play()
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }

    func playSFX(_ name: String) {
        guard !isMuted else { return }
        if let player = sfxPlayers[name] {
            player.currentTime = 0
            player.play()
        } else if let url = findAudioURL(named: name, ext: "wav") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.play()
                sfxPlayers[name] = player
            } catch {
                print("SFX play error for \(name): \(error)")
            }
        }
    }
}
