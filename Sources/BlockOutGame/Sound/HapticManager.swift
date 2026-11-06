import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public final class HapticManager {
    public static let shared = HapticManager()

    public var isEnabled: Bool = true

    private init() {}

    public func lightTap() {
        guard isEnabled else { return }
        #if os(iOS)
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.prepare()
        gen.impactOccurred()
        #endif
    }

    public func mediumTap() {
        guard isEnabled else { return }
        #if os(iOS)
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.prepare()
        gen.impactOccurred()
        #endif
    }

    public func heavyTap() {
        guard isEnabled else { return }
        #if os(iOS)
        let gen = UIImpactFeedbackGenerator(style: .heavy)
        gen.prepare()
        gen.impactOccurred()
        #endif
    }

    public func success() {
        guard isEnabled else { return }
        #if os(iOS)
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(.success)
        #endif
    }

    public func warning() {
        guard isEnabled else { return }
        #if os(iOS)
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(.warning)
        #endif
    }
}

