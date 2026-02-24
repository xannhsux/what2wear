import Foundation
import UIKit

/// Calls the Replicate PhotoMaker API to generate a face-swapped avatar.
///
/// Flow:
///  1. `createPrediction(base64:)` → POST /predictions → returns prediction `id`
///  2. `poll(id:)` → GET /predictions/{id} every 1 s until `"succeeded"` or `"failed"`
///  3. Returns the output image URL from the prediction result
struct ReplicateService {

    private let apiKey  = Constants.replicateAPIKey
    private let baseURL = Constants.replicateBaseURL

    // MARK: - Public

    /// Generates an avatar from the user's selfie.
    /// - Parameter selfieImage: The photo captured/selected by the user.
    /// - Returns: The remote URL of the generated avatar image.
    func generateAvatar(selfieImage: UIImage) async throws -> URL {
        guard !apiKey.isEmpty, apiKey != "YOUR_REPLICATE_API_KEY_HERE" else {
            throw APIError.missingAPIKey
        }

        let base64Selfie = try encodeImage(selfieImage)
        let predictionID = try await createPrediction(base64: base64Selfie)
        return try await poll(id: predictionID)
    }

    // MARK: - Image encoding

    private func encodeImage(_ image: UIImage) throws -> String {
        let resized = downscale(image, maxDimension: Constants.Image.maxUploadDimension)
        guard let data = resized.jpegData(compressionQuality: Constants.Image.compressionQuality) else {
            throw APIError.imageConversionFailed
        }
        // Replicate accepts data-URI strings for image inputs
        return "data:image/jpeg;base64,\(data.base64EncodedString())"
    }

    private func downscale(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size    = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }
        let scale   = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    // MARK: - Prediction creation

    private func createPrediction(base64 selfieURI: String) async throws -> String {
        let url = URL(string: "\(baseURL)/predictions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addAuthHeaders(to: &request)

        // Payload matches the exact structure specified in the project brief
        let body: [String: Any] = [
            "version": Constants.photoMakerVersion,
            "input": [
                "prompt": Constants.avatarPrompt,
                "input_image": selfieURI,
                "negative_prompt": Constants.avatarNegativePrompt,
                "num_outputs": 1,
                "style_strength_ratio": 20
            ] as [String: Any]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let id   = json["id"] as? String
        else {
            let raw = String(data: data, encoding: .utf8) ?? "<no body>"
            throw APIError.invalidResponse("Missing 'id' in prediction response: \(raw)")
        }

        return id
    }

    // MARK: - Polling

    private func poll(id: String) async throws -> URL {
        let pollURL = URL(string: "\(baseURL)/predictions/\(id)")!
        var request = URLRequest(url: pollURL)
        addAuthHeaders(to: &request)

        for attempt in 0 ..< Constants.Polling.maxAttempts {
            // Wait first — newly created predictions are never immediately ready
            try await Task.sleep(nanoseconds: Constants.Polling.intervalNanoseconds)

            let (data, response) = try await URLSession.shared.data(for: request)
            try validate(response, data: data)

            guard
                let json   = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let status = json["status"] as? String
            else {
                continue
            }

            switch status {
            case "succeeded":
                return try extractOutputURL(from: json)

            case "failed", "canceled":
                let errorMsg = (json["error"] as? String) ?? "Unknown error from model"
                throw APIError.generationFailed(errorMsg)

            default:
                // "starting" or "processing" — keep polling
                let _ = attempt  // suppress unused warning
                continue
            }
        }

        throw APIError.timeout
    }

    private func extractOutputURL(from json: [String: Any]) throws -> URL {
        // PhotoMaker returns an array of image URLs
        if let arr   = json["output"] as? [String],
           let first = arr.first,
           let url   = URL(string: first) {
            return url
        }
        // Fallback: bare string URL
        if let str = json["output"] as? String,
           let url = URL(string: str) {
            return url
        }
        throw APIError.invalidResponse("Cannot parse output URL from: \(json["output"] ?? "nil")")
    }

    // MARK: - Helpers

    private func addAuthHeaders(to request: inout URLRequest) {
        request.setValue("Token \(apiKey)",  forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse("Non-HTTP response received")
        }
        guard (200 ... 299).contains(http.statusCode) else {
            if http.statusCode == 401 || http.statusCode == 403 {
                throw APIError.unauthorized
            }
            let body = String(data: data, encoding: .utf8)
            throw APIError.serverError(http.statusCode, body)
        }
    }
}
