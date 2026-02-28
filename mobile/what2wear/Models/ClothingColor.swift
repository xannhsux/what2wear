import Foundation
import SwiftUI

struct ClothingColor: Identifiable {
    let name: String
    let hex: String
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat

    var id: String { name }

    var color: Color { Color(hex: hex) }

    static let palette: [ClothingColor] = [
        ClothingColor(name: "Black",  hex: "1A1A1A", r: 0.10, g: 0.10, b: 0.10),
        ClothingColor(name: "White",  hex: "F5F5F5", r: 0.96, g: 0.96, b: 0.96),
        ClothingColor(name: "Gray",   hex: "9E9E9E", r: 0.62, g: 0.62, b: 0.62),
        ClothingColor(name: "Navy",   hex: "1B2A4A", r: 0.11, g: 0.16, b: 0.29),
        ClothingColor(name: "Blue",   hex: "4A90D9", r: 0.29, g: 0.56, b: 0.85),
        ClothingColor(name: "Red",    hex: "D94444", r: 0.85, g: 0.27, b: 0.27),
        ClothingColor(name: "Pink",   hex: "E991B8", r: 0.91, g: 0.57, b: 0.72),
        ClothingColor(name: "Green",  hex: "4A9E6A", r: 0.29, g: 0.62, b: 0.42),
        ClothingColor(name: "Beige",  hex: "D4C5A9", r: 0.83, g: 0.77, b: 0.66),
        ClothingColor(name: "Brown",  hex: "8B5E3C", r: 0.55, g: 0.37, b: 0.24),
        ClothingColor(name: "Yellow", hex: "E5C94E", r: 0.90, g: 0.79, b: 0.31),
        ClothingColor(name: "Orange", hex: "E08A3C", r: 0.88, g: 0.54, b: 0.24),
        ClothingColor(name: "Purple", hex: "7E57C2", r: 0.49, g: 0.34, b: 0.76),
    ]

    /// Find the closest named color to an arbitrary RGB value using Euclidean distance.
    static func closest(to r: CGFloat, g: CGFloat, b: CGFloat) -> ClothingColor {
        palette.min(by: { a, bColor in
            let distA = pow(a.r - r, 2) + pow(a.g - g, 2) + pow(a.b - b, 2)
            let distB = pow(bColor.r - r, 2) + pow(bColor.g - g, 2) + pow(bColor.b - b, 2)
            return distA < distB
        }) ?? palette[0]
    }
}
