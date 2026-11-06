import SwiftUI

/// 10 vibrant toy brick colors with 3D bevel shades, matching the Android palette
public enum BlockColor: String, CaseIterable, Codable, Identifiable, Sendable {
    case blue = "Blue"
    case red = "Red"
    case green = "Green"
    case yellow = "Yellow"
    case orange = "Orange"
    case purple = "Purple"
    case white = "White"
    case black = "Black"
    case pink = "Pink"
    case cyan = "Cyan"

    public var id: String { rawValue }

    public var displayName: String { rawValue }

    public var mainColor: Color {
        switch self {
        case .blue:   return Color(hex: 0x00A2FF)
        case .red:    return Color(hex: 0xFF334B)
        case .green:  return Color(hex: 0x00E676)
        case .yellow: return Color(hex: 0xFFB800)
        case .orange: return Color(hex: 0xFFFF7A00)
        case .purple: return Color(hex: 0xA855F7)
        case .white:  return Color(hex: 0xE2E8F0)
        case .black:  return Color(hex: 0x333642)
        case .pink:   return Color(hex: 0xFFFF4081)
        case .cyan:   return Color(hex: 0x00E5FF)
        }
    }

    public var darkColor: Color {
        switch self {
        case .blue:   return Color(hex: 0x006BB3)
        case .red:    return Color(hex: 0xB8182B)
        case .green:  return Color(hex: 0x00964F)
        case .yellow: return Color(hex: 0xB38000)
        case .orange: return Color(hex: 0xB35500)
        case .purple: return Color(hex: 0x7322BD)
        case .white:  return Color(hex: 0x94A3B8)
        case .black:  return Color(hex: 0x1E2027)
        case .pink:   return Color(hex: 0xC51162)
        case .cyan:   return Color(hex: 0x0099AB)
        }
    }

    public var lightColor: Color {
        switch self {
        case .blue:   return Color(hex: 0x68C8FF)
        case .red:    return Color(hex: 0xFFFF7A8A)
        case .green:  return Color(hex: 0x66FFA6)
        case .yellow: return Color(hex: 0xFFFFCF4D)
        case .orange: return Color(hex: 0xFFFFA54D)
        case .purple: return Color(hex: 0xC48BFA)
        case .white:  return Color(hex: 0xFFFFFF)
        case .black:  return Color(hex: 0x535768)
        case .pink:   return Color(hex: 0xFFFF80AB)
        case .cyan:   return Color(hex: 0x6EFFFF)
        }
    }

    public var studColor: Color {
        switch self {
        case .blue:   return Color(hex: 0x38B6FF)
        case .red:    return Color(hex: 0xFFFF5266)
        case .green:  return Color(hex: 0x26EB8A)
        case .yellow: return Color(hex: 0xFFFFC21A)
        case .orange: return Color(hex: 0xFFFF8F26)
        case .purple: return Color(hex: 0xB56EF8)
        case .white:  return Color(hex: 0xCBD5E1)
        case .black:  return Color(hex: 0x424656)
        case .pink:   return Color(hex: 0xFFFF5C93)
        case .cyan:   return Color(hex: 0x26EAFF)
        }
    }

    public var hexCode: String {
        switch self {
        case .blue:   return "#00A2FF"
        case .red:    return "#FF334B"
        case .green:  return "#00E676"
        case .yellow: return "#FFB800"
        case .orange: return "#FF7A00"
        case .purple: return "#A855F7"
        case .white:  return "#E2E8F0"
        case .black:  return "#333642"
        case .pink:   return "#FF4081"
        case .cyan:   return "#00E5FF"
        }
    }

    public static func fromName(_ name: String) -> BlockColor {
        allCases.first { $0.rawValue.caseInsensitiveCompare(name) == .orderedSame } ?? .blue
    }
}

// Color hex helper
public extension Color {
    init(hex: UInt64, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    init(hex: Int, alpha: Double = 1.0) {
        self.init(hex: UInt64(bitPattern: Int64(hex)), alpha: alpha)
    }
}

