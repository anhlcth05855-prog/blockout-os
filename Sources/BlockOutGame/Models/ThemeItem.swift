import SwiftUI

public struct ThemeItem: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var name: String
    public var description: String
    public var price: Int
    public var isUnlocked: Bool
    public var backgroundStartColorHex: UInt64
    public var backgroundEndColorHex: UInt64
    public var boardBgColorHex: UInt64
    public var boardBorderColorHex: UInt64

    public init(
        id: String,
        name: String,
        description: String,
        price: Int,
        isUnlocked: Bool,
        backgroundStartColorHex: UInt64,
        backgroundEndColorHex: UInt64,
        boardBgColorHex: UInt64,
        boardBorderColorHex: UInt64
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.isUnlocked = isUnlocked
        self.backgroundStartColorHex = backgroundStartColorHex
        self.backgroundEndColorHex = backgroundEndColorHex
        self.boardBgColorHex = boardBgColorHex
        self.boardBorderColorHex = boardBorderColorHex
    }

    public var backgroundStartColor: Color { Color(hex: backgroundStartColorHex) }
    public var backgroundEndColor: Color { Color(hex: backgroundEndColorHex) }
    public var boardBgColor: Color { Color(hex: boardBgColorHex) }
    public var boardBorderColor: Color { Color(hex: boardBorderColorHex) }
}

