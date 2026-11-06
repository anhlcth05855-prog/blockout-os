import Foundation
import AudioToolbox

public final class SoundManager: ObservableObject {
    public static let shared = SoundManager()

    @Published public var soundEnabled: Bool = true
    @Published public var musicEnabled: Bool = true
    @Published public var hapticEnabled: Bool = true

    private init() {}

    public func playClick() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Tick
    }

    public func playSlide() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1105) // Soft click
    }

    public func playBlockEscape() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1057) // Bright chime
    }

    public func playCombo(multiplier: Int) {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1025) // Higher chime
    }

    public func playWin() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1026) // Fanfare bell
    }

    public func playGameOver() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1053) // Low tone
    }

    public func playHammerSmash() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1052) // Smash/drop
    }
}

