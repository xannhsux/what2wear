import UIKit
import Vision
import CoreImage

/// On-device clothing classification using Apple Vision (type) and Core Image (color).
struct ClothingClassifierService {

    // MARK: - Type classification

    /// Maps Vision classifier identifiers to our clothing categories.
    private let vnIdentifierMap: [String: ClothingCategory] = [
        "hoodie":           .hoodie,
        "jacket":           .jacket,
        "jeans":            .jeans,
        "lab_coat":         .coat,
        "poncho":           .jacket,
        "kilt":             .skirt,
        "kimono":           .dress,
        "cardigan":         .cardigan,
        "sweatshirt":       .sweater,
        "jersey":           .tshirt,
        "trench_coat":      .coat,
        "fur_coat":         .coat,
        "suit":             .other,
        "tuxedo":           .other,
        "military_uniform": .other,
        "miniskirt":        .skirt,
        "swimming_trunks":  .shorts,
        "bikini":           .other,
        "abaya":            .dress,
    ]

    /// Uses VNClassifyImageRequest to detect the clothing type.
    /// Returns `.other` if classification is unavailable (e.g. on Simulator) or uncertain.
    func classifyType(image: UIImage) async -> ClothingCategory {
        guard let cgImage = image.cgImage else { return .other }

        // VNClassifyImageRequest may not be supported on the Simulator.
        // Check availability first to avoid VNErrorUnsupportedRevision (code 9).
        guard Self.visionClassifySupported else {
            print("[Classifier] VNClassifyImageRequest not supported on this device — select category manually.")
            return .other
        }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    print("[Classifier] Vision error: \(error.localizedDescription)")
                    continuation.resume(returning: .other)
                    return
                }

                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: .other)
                    return
                }

                let clothingResults = results.filter { self.vnIdentifierMap.keys.contains($0.identifier) }

                if let best = clothingResults.max(by: { $0.confidence < $1.confidence }),
                   best.confidence > 0.1,
                   let category = self.vnIdentifierMap[best.identifier] {
                    continuation.resume(returning: category)
                } else {
                    continuation.resume(returning: .other)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("[Classifier] Vision perform failed: \(error.localizedDescription)")
                continuation.resume(returning: .other)
            }
        }
    }

    // MARK: - Support check

    /// Cached check — try calling supportedIdentifiers() once to see if Vision classify works.
    private static let visionClassifySupported: Bool = {
        let request = VNClassifyImageRequest()
        do {
            _ = try request.supportedIdentifiers()
            return true
        } catch {
            return false
        }
    }()

    // MARK: - Color extraction

    /// Extracts the dominant color from the image using CIAreaAverage.
    func extractDominantColor(image: UIImage) -> ClothingColor {
        guard let ciImage = CIImage(image: image) else {
            return ClothingColor.palette[0]
        }

        let extent = ciImage.extent
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: extent)
        ]),
        let outputImage = filter.outputImage else {
            return ClothingColor.palette[0]
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        let r = CGFloat(bitmap[0]) / 255.0
        let g = CGFloat(bitmap[1]) / 255.0
        let b = CGFloat(bitmap[2]) / 255.0

        return ClothingColor.closest(to: r, g: g, b: b)
    }
}
