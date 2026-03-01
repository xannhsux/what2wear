import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

/// On-device clothing classification using Apple Vision (type + tags) and Core Image (color).
struct ClothingClassifierService {

    // MARK: - Type classification (5 categories)

    /// Maps Vision classifier identifiers to the 5 simplified categories.
    private let vnIdentifierMap: [String: ClothingCategory] = [
        // Top
        "hoodie":           .top,
        "sweatshirt":       .top,
        "jersey":           .top,
        "cardigan":         .top,

        // Outerwear
        "jacket":           .outerwear,
        "lab_coat":         .outerwear,
        "poncho":           .outerwear,
        "trench_coat":      .outerwear,
        "fur_coat":         .outerwear,

        // Bottom
        "jeans":            .bottom,
        "swimming_trunks":  .bottom,
        "miniskirt":        .bottom,
        "kilt":             .bottom,

        // Dress
        "kimono":           .dress,
        "abaya":            .dress,
    ]

    /// Maps Vision identifiers to fine-grained tags.
    private let vnTagMap: [String: String] = [
        "hoodie":           "hoodie",
        "jacket":           "jacket",
        "jeans":            "jeans",
        "lab_coat":         "coat",
        "poncho":           "poncho",
        "kilt":             "skirt",
        "kimono":           "kimono",
        "cardigan":         "cardigan",
        "sweatshirt":       "sweater",
        "jersey":           "jersey",
        "trench_coat":      "trench coat",
        "fur_coat":         "fur coat",
        "suit":             "suit",
        "tuxedo":           "tuxedo",
        "military_uniform": "uniform",
        "miniskirt":        "miniskirt",
        "swimming_trunks":  "shorts",
        "bikini":           "bikini",
        "abaya":            "abaya",
    ]

    private let ciContext = CIContext()

    // MARK: - Person segmentation (background removal)

    /// Removes the background from a photo. Returns the person on a white background.
    func removeBackground(image: UIImage) async -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let mask = await generatePersonMask(cgImage: cgImage)
        guard let mask = mask else { return image }

        let ciImage = CIImage(cgImage: cgImage)
        let maskCI = CIImage(cgImage: mask)

        let scaleX = ciImage.extent.width / maskCI.extent.width
        let scaleY = ciImage.extent.height / maskCI.extent.height
        let scaledMask = maskCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let white = CIImage(color: CIColor.white).cropped(to: ciImage.extent)

        guard let blended = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputBackgroundImageKey: white,
            kCIInputMaskImageKey: scaledMask,
        ])?.outputImage else {
            return image
        }

        let cropped = cropToMask(blendedImage: blended, mask: scaledMask, fullExtent: ciImage.extent)

        guard let result = ciContext.createCGImage(cropped, from: cropped.extent) else {
            return image
        }
        return UIImage(cgImage: result, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Extracts clothing region color (person minus head area).
    func extractClothingRegionColor(image: UIImage) async -> ClothingColor {
        guard let cgImage = image.cgImage else { return ClothingColor.palette[0] }

        let mask = await generatePersonMask(cgImage: cgImage)

        let ciImage = CIImage(cgImage: cgImage)
        let imageExtent = ciImage.extent

        if let mask = mask {
            let maskCI = CIImage(cgImage: mask)
            let scaleX = imageExtent.width / maskCI.extent.width
            let scaleY = imageExtent.height / maskCI.extent.height
            let scaledMask = maskCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

            let personBounds = findMaskBounds(mask: scaledMask, in: imageExtent)

            let headCutoff = personBounds.height * 0.30
            let clothingRect = CGRect(
                x: personBounds.origin.x,
                y: personBounds.origin.y,
                width: personBounds.width,
                height: personBounds.height - headCutoff
            )

            guard let masked = CIFilter(name: "CIBlendWithMask", parameters: [
                kCIInputImageKey: ciImage,
                kCIInputBackgroundImageKey: CIImage(color: CIColor.clear).cropped(to: imageExtent),
                kCIInputMaskImageKey: scaledMask,
            ])?.outputImage else {
                return averageColor(ciImage: ciImage, rect: clothingRect)
            }

            return averageColor(ciImage: masked, rect: clothingRect)
        }

        return averageColor(ciImage: ciImage, rect: imageExtent)
    }

    // MARK: - Type classification

    /// Uses VNClassifyImageRequest to detect the clothing type (5 categories).
    func classifyType(image: UIImage) async -> ClothingCategory {
        guard let cgImage = image.cgImage else { return .top }

        guard Self.visionClassifySupported else {
            return .top
        }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    print("[Classifier] Vision error: \(error.localizedDescription)")
                    continuation.resume(returning: .top)
                    return
                }

                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: .top)
                    return
                }

                let clothingResults = results.filter { self.vnIdentifierMap.keys.contains($0.identifier) }

                if let best = clothingResults.max(by: { $0.confidence < $1.confidence }),
                   best.confidence > 0.1,
                   let category = self.vnIdentifierMap[best.identifier] {
                    continuation.resume(returning: category)
                } else {
                    continuation.resume(returning: .top)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: .top)
            }
        }
    }

    // MARK: - Tag generation

    /// Generates descriptive tags from Vision classification results.
    func generateTags(image: UIImage) async -> [String] {
        guard let cgImage = image.cgImage, Self.visionClassifySupported else { return [] }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                var tags: [String] = []
                for result in results where result.confidence > 0.05 {
                    if let tag = self.vnTagMap[result.identifier] {
                        tags.append(tag)
                    }
                }
                continuation.resume(returning: Array(tags.prefix(5)))
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }

    /// Attempts to detect material from image (basic heuristic based on texture).
    func detectMaterial(image: UIImage) async -> String {
        // Basic heuristic — defaults to empty. Can be improved with a trained model.
        return ""
    }

    // MARK: - Support check

    private static let visionClassifySupported: Bool = {
        let request = VNClassifyImageRequest()
        do {
            _ = try request.supportedIdentifiers()
            return true
        } catch {
            return false
        }
    }()

    // MARK: - Private helpers

    private func generatePersonMask(cgImage: CGImage) async -> CGImage? {
        await withCheckedContinuation { continuation in
            let request = VNGeneratePersonSegmentationRequest()
            request.qualityLevel = .accurate

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                guard let result = request.results?.first else {
                    continuation.resume(returning: nil)
                    return
                }
                let maskCI = CIImage(cvPixelBuffer: result.pixelBuffer)
                let maskCG = ciContext.createCGImage(maskCI, from: maskCI.extent)
                continuation.resume(returning: maskCG)
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }

    private func findMaskBounds(mask: CIImage, in extent: CGRect) -> CGRect {
        let insetX = extent.width * 0.1
        return CGRect(
            x: extent.origin.x + insetX,
            y: extent.origin.y,
            width: extent.width - insetX * 2,
            height: extent.height
        )
    }

    private func cropToMask(blendedImage: CIImage, mask: CIImage, fullExtent: CGRect) -> CIImage {
        let insetX = fullExtent.width * 0.05
        let insetY = fullExtent.height * 0.05
        let cropRect = fullExtent.insetBy(dx: insetX, dy: insetY)
        return blendedImage.cropped(to: cropRect)
    }

    private func averageColor(ciImage: CIImage, rect: CGRect) -> ClothingColor {
        let clamped = rect.intersection(ciImage.extent)
        guard !clamped.isEmpty else { return ClothingColor.palette[0] }

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: clamped)
        ]),
        let outputImage = filter.outputImage else {
            return ClothingColor.palette[0]
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        ciContext.render(
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
