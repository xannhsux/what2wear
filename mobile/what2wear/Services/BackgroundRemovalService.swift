import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision

/// Handles transparent background generation for avatar images.
struct BackgroundRemovalService {

    private let ciContext = CIContext()

    // MARK: - Public

    /// Removes the background and returns a transparent PNG image.
    func makeTransparent(image: UIImage) async -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let mask = await generatePersonMask(cgImage: cgImage)
        guard let mask = mask else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let maskCI = CIImage(cgImage: mask)

        // Scale mask to match image size
        let scaleX = ciImage.extent.width / maskCI.extent.width
        let scaleY = ciImage.extent.height / maskCI.extent.height
        let scaledMask = maskCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // Transparent background
        let clear = CIImage(color: CIColor.clear).cropped(to: ciImage.extent)

        guard let blended = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputBackgroundImageKey: clear,
            kCIInputMaskImageKey: scaledMask,
        ])?.outputImage else {
            return nil
        }

        // Crop to person bounds
        let cropped = cropToPersonBounds(blendedImage: blended, mask: scaledMask, fullExtent: ciImage.extent)

        guard let result = ciContext.createCGImage(cropped, from: cropped.extent) else {
            return nil
        }

        return UIImage(cgImage: result, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Takes a transparent image and adds a white background.
    func addWhiteBackground(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let ciImage = CIImage(cgImage: cgImage)
        let white = CIImage(color: CIColor.white).cropped(to: ciImage.extent)

        // Composite transparent image over white
        let composited = ciImage.composited(over: white)

        guard let result = ciContext.createCGImage(composited, from: composited.extent) else {
            return nil
        }
        return UIImage(cgImage: result, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Private

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
                print("[BackgroundRemoval] Person segmentation failed: \(error.localizedDescription)")
                continuation.resume(returning: nil)
            }
        }
    }

    private func cropToPersonBounds(blendedImage: CIImage, mask: CIImage, fullExtent: CGRect) -> CIImage {
        let insetX = fullExtent.width * 0.05
        let insetY = fullExtent.height * 0.05
        let cropRect = fullExtent.insetBy(dx: insetX, dy: insetY)
        return blendedImage.cropped(to: cropRect)
    }
}
