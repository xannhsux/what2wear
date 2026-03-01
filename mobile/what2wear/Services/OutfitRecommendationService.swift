import Foundation

/// Generates outfit recommendations from the user's closet items.
/// No weather or occasion — purely based on item combinations and color coordination.
struct OutfitRecommendationService {

    private static let neutralColors: Set<String> = ["Black", "White", "Gray", "Beige"]

    // MARK: - Public

    /// Returns up to `maxOutfits` outfit recommendations from the user's closet.
    /// Requires at least `minItems` items to generate recommendations.
    func recommend(
        items: [ClothingItem],
        maxOutfits: Int = Constants.Recommendation.maxOutfits,
        minItems: Int = Constants.Recommendation.minClosetItems
    ) -> [Outfit] {
        guard items.count >= minItems else { return [] }

        let tops = items.filter { $0.category == .top }
        let bottoms = items.filter { $0.category == .bottom }
        let dresses = items.filter { $0.category == .dress }
        let outerwear = items.filter { $0.category == .outerwear }
        let shoes = items.filter { $0.category == .shoes }

        var scored: [(Outfit, Double)] = []

        // Dress combos (optionally + outerwear + shoes)
        for dress in dresses {
            var itemIds = [dress.id]
            let score = 2.0

            // Optionally add outerwear
            if let ow = bestOuterwearMatch(for: [dress], from: outerwear) {
                itemIds.append(ow.id)
            }

            // Optionally add shoes
            if let shoe = bestShoesMatch(for: [dress], from: shoes) {
                itemIds.append(shoe.id)
            }

            if nonNeutralColorCount(itemIds: itemIds, items: items) <= Constants.Recommendation.maxNonNeutralColors {
                scored.append((Outfit(itemIds: itemIds), score))
            }
        }

        // Top + bottom combos (optionally + outerwear + shoes)
        for top in tops {
            for bottom in bottoms {
                var itemIds = [top.id, bottom.id]
                let colorScore = colorCoordinationScore(a: top, b: bottom)

                // Optionally add outerwear
                if let ow = bestOuterwearMatch(for: [top, bottom], from: outerwear) {
                    itemIds.append(ow.id)
                }

                // Optionally add shoes
                if let shoe = bestShoesMatch(for: [top, bottom], from: shoes) {
                    itemIds.append(shoe.id)
                }

                // Enforce max 3 non-neutral colors
                if nonNeutralColorCount(itemIds: itemIds, items: items) <= Constants.Recommendation.maxNonNeutralColors {
                    scored.append((Outfit(itemIds: itemIds), colorScore))
                }
            }
        }

        // Sort by score descending, take top N
        scored.sort { $0.1 > $1.1 }
        return Array(scored.prefix(maxOutfits).map { $0.0 })
    }

    // MARK: - Color coordination

    private func colorCoordinationScore(a: ClothingItem, b: ClothingItem) -> Double {
        let aNeutral = Self.neutralColors.contains(a.colorName)
        let bNeutral = Self.neutralColors.contains(b.colorName)

        if aNeutral && bNeutral { return 1.5 }
        if aNeutral || bNeutral { return 2.0 }
        if a.colorName == b.colorName { return 0.0 }
        return 1.0
    }

    private func nonNeutralColorCount(itemIds: [String], items: [ClothingItem]) -> Int {
        let resolved = itemIds.compactMap { id in items.first { $0.id == id } }
        let nonNeutral = resolved.filter { !Self.neutralColors.contains($0.colorName) }
        let uniqueColors = Set(nonNeutral.map { $0.colorName })
        return uniqueColors.count
    }

    // MARK: - Matching helpers

    private func bestOuterwearMatch(for baseItems: [ClothingItem], from outerwear: [ClothingItem]) -> ClothingItem? {
        guard !outerwear.isEmpty else { return nil }
        // Pick outerwear that color-coordinates best with base items
        return outerwear.max(by: { a, b in
            let scoreA = baseItems.map { colorCoordinationScore(a: $0, b: a) }.reduce(0, +)
            let scoreB = baseItems.map { colorCoordinationScore(a: $0, b: b) }.reduce(0, +)
            return scoreA < scoreB
        })
    }

    private func bestShoesMatch(for baseItems: [ClothingItem], from shoes: [ClothingItem]) -> ClothingItem? {
        guard !shoes.isEmpty else { return nil }
        return shoes.max(by: { a, b in
            let scoreA = baseItems.map { colorCoordinationScore(a: $0, b: a) }.reduce(0, +)
            let scoreB = baseItems.map { colorCoordinationScore(a: $0, b: b) }.reduce(0, +)
            return scoreA < scoreB
        })
    }
}
