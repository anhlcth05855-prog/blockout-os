import Foundation

public enum SlideDirection: String, Codable, CaseIterable, Sendable {
    case horizontal
    case vertical
    case all

    public var canMoveHorizontal: Bool {
        self == .horizontal || self == .all
    }

    public var canMoveVertical: Bool {
        self == .vertical || self == .all
    }
}

