import Foundation
import UIKit

/// Calls tencentarc/photomaker on Replicate.
///
/// Flow:
///  1. Encode avatar.png + selfie as base64 data URIs
///  2. POST /models/tencentarc/photomaker/predictions
///     input_image = [avatarURI, selfieURI]  ← array, not string
///  3. Poll every 3 s until succeeded/failed
///  4. Download and return the result image
struct ReplicateService {

    private let apiKey  = Constants.replicateAPIKey
    private let baseURL = Constants.replicateBaseURL

    // MARK: - Public

    func generateAvatar(selfieImage: UIImage) async throws -> UIImage {
        guard !apiKey.isEmpty, apiKey != "YOUR_REPLICATE_API_KEY_HERE" else {
            throw APIError.missingAPIKey
        }
        do {
            let avatarImage = try loadBaseAvatar()
            guard let avatarURI = toDataURI(avatarImage),
                  let selfieURI = toDataURI(selfieImage) else {
                throw APIError.imageConversionFailed
            }
            let id        = try await createPrediction(avatarURI: avatarURI, selfieURI: selfieURI)
            let outputURL = try await poll(id: id)
            return try await downloadImage(from: outputURL)
        } catch let e as URLError
            where e.code == .notConnectedToInternet
               || e.code == .networkConnectionLost
               || e.code == .cannotConnectToHost
               || e.code == .timedOut {
            throw APIError.networkUnavailable
        }
    }

    // MARK: - Load avatar from Assets

    private func loadBaseAvatar() throws -> UIImage {
        if let url  = Bundle.main.url(forResource: "avatar", withExtension: "png"),
           let data = try? Data(contentsOf: url),
           let img  = UIImage(data: data) { return img }
        if let img = UIImage(named: "avatar") { return img }
        throw APIError.baseImageMissing
    }

    // MARK: - Encode image as base64 data URI

    private func toDataURI(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        return "data:image/jpeg;base64,\(data.base64EncodedString())"
    }

    // MARK: - Create prediction

    private func createPrediction(avatarURI: String, selfieURI: String) async throws -> String {
        // Model-based endpoint — no version hash needed, always uses latest
        var req = URLRequest(url: URL(string: "\(baseURL)/models/tencentarc/photomaker/predictions")!, timeoutInterval: 60)
        req.httpMethod = "POST"
        addHeaders(to: &req)

        // input_image must be an ARRAY of images
        // PhotoMaker extracts the face from these reference photos
        let body: [String: Any] = [
            "input": [
                "input_image":        [avatarURI, selfieURI],   // ← array
                "prompt":             "a photo of a person img, white sleeveless tank top, blue straight-leg jeans, barefoot, full body standing, light gray background, photographic",
                "negative_prompt":    "deformed, ugly, blurry, extra limbs, bad anatomy, cartoon",
                "style_name":         "Photographic (Default)",
                "num_outputs":        1,
                "num_inference_steps": 50,
                "guidance_scale":     5
            ] as [String: Any]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        try validate(response, data: data)

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let id   = json["id"] as? String else {
            throw APIError.invalidResponse("No prediction id: \(String(data: data, encoding: .utf8) ?? "")")
        }
        return id
    }

    // MARK: - Poll

    private func poll(id: String) async throws -> URL {
        var req = URLRequest(url: URL(string: "\(baseURL)/predictions/\(id)")!, timeoutInterval: 30)
        addHeaders(to: &req)

        try await Task.sleep(nanoseconds: 20_000_000_000)  // PhotoMaker needs ~20–40 s

        for _ in 0..<Constants.Polling.maxAttempts {
            let (data, response) = try await URLSession.shared.data(for: req)
            try validate(response, data: data)

            guard let json   = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? String else {
                try await Task.sleep(nanoseconds: Constants.Polling.intervalNanoseconds)
                continue
            }

            switch status {
            case "succeeded":
                return try extractOutputURL(from: json)
            case "failed", "canceled":
                throw APIError.generationFailed((json["error"] as? String) ?? "Generation failed")
            default:
                try await Task.sleep(nanoseconds: Constants.Polling.intervalNanoseconds)
            }
        }
        throw APIError.timeout
    }

    private func extractOutputURL(from json: [String: Any]) throws -> URL {
        if let arr = json["output"] as? [String], let first = arr.first, let url = URL(string: first) { return url }
        if let str = json["output"] as? String,                          let url = URL(string: str)   { return url }
        throw APIError.invalidResponse("Cannot parse output URL")
    }

    // MARK: - Download result

    private func downloadImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response, data: data)
        guard let image = UIImage(data: data) else {
            throw APIError.invalidResponse("Downloaded data is not an image")
        }
        return image
    }

    // MARK: - Helpers

    private func addHeaders(to request: inout URLRequest) {
        request.setValue("Token \(apiKey)",  forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse("Non-HTTP response")
        }
        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 401 || http.statusCode == 403 { throw APIError.unauthorized }
            throw APIError.serverError(http.statusCode, String(data: data, encoding: .utf8))
        }
    }
}
