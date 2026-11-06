import Foundation

public enum ExitSide: String, Codable, CaseIterable, Sendable {
    case top
    case bottom
    case left
    case right

    public var isVertical: Bool {
        self == .top || self == .bottom
    }

    public var isHorizontal: Bool {
        self == .left || self == .right
    }

    public var opposite: ExitSide {
        switch self {
        case .top:    return .bottom
        case .bottom: return .top
        case .left:   return .right
        case .right:  return .left
        }
    }
}

