import Foundation
import UIKit

/// Calls WaveSpeed AI's FLUX Kontext Pro for full-body avatar generation.
///
/// Flow:
///  1. Encode selfie as base64 data URI
///  2. POST to /wavespeed-ai/flux-kontext-pro  (async mode)
///  3. Poll /predictions/{id}/result every 3 s until completed/failed
///  4. Download and return the result image
struct WaveSpeedService {

    private let apiKey  = Constants.waveSpeedAPIKey
    private let baseURL = Constants.waveSpeedBaseURL

    private let avatarPrompt =
        "Transform this into a full body photo of the same person, standing straight facing the camera, " +
        "wearing a plain white tank top and light blue jeans, barefoot, arms relaxed at sides, " +
        "clean white background, fashion catalog style, studio lighting, high quality photography. " +
        "Keep the exact same face, skin tone, hair style and hair color."

    // MARK: - Public

    func generateAvatar(selfieImage: UIImage) async throws -> UIImage {
        guard !apiKey.isEmpty, apiKey != "YOUR_WAVESPEED_API_KEY_HERE" else {
            throw APIError.missingAPIKey
        }

        do {
            guard let selfieURI = toDataURI(selfieImage) else {
                throw APIError.imageConversionFailed
            }

            let taskId    = try await submitGeneration(imageDataURI: selfieURI)
            let outputURL = try await poll(taskId: taskId)
            return try await downloadImage(from: outputURL)
        } catch let e as URLError
            where e.code == .notConnectedToInternet
               || e.code == .networkConnectionLost
               || e.code == .cannotConnectToHost
               || e.code == .cannotFindHost
               || e.code == .dnsLookupFailed
               || e.code == .timedOut {
            throw APIError.networkUnavailable
        }
    }

    // MARK: - Encode image as base64 data URI

    private func toDataURI(_ image: UIImage) -> String? {
        // Resize to max 1024 on longest side for faster upload
        let resized = resize(image, maxDimension: Constants.Image.maxUploadDimension)
        guard let data = resized.jpegData(compressionQuality: Constants.Image.compressionQuality) else { return nil }
        return "data:image/jpeg;base64,\(data.base64EncodedString())"
    }

    private func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        if ratio >= 1 { return image }
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }

    // MARK: - Submit generation

    private func submitGeneration(imageDataURI: String) async throws -> String {
        let url = URL(string: "\(baseURL)/wavespeed-ai/flux-kontext-pro")!
        var req = URLRequest(url: url, timeoutInterval: 60)
        req.httpMethod = "POST"
        addHeaders(to: &req)

        let body: [String: Any] = [
            "prompt": avatarPrompt,
            "image": imageDataURI,
            "output_format": "png",
            "enable_base64_output": false,
            "enable_sync_mode": false,
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)
        try validate(response, data: data)

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let code = json["code"] as? Int, code == 200,
              let taskData = json["data"] as? [String: Any],
              let taskId = taskData["id"] as? String else {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw APIError.invalidResponse("No task id in response: \(raw.prefix(200))")
        }

        return taskId
    }

    // MARK: - Poll

    private func poll(taskId: String) async throws -> URL {
        let pollURL = URL(string: "\(baseURL)/predictions/\(taskId)/result")!
        var req = URLRequest(url: pollURL, timeoutInterval: 30)
        addHeaders(to: &req)

        // Give WaveSpeed a head start before first poll
        try await Task.sleep(nanoseconds: 5_000_000_000)

        for _ in 0..<Constants.Polling.maxAttempts {
            let (data, response) = try await URLSession.shared.data(for: req)
            try validate(response, data: data)

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let taskData = json["data"] as? [String: Any],
                  let status = taskData["status"] as? String else {
                try await Task.sleep(nanoseconds: Constants.Polling.intervalNanoseconds)
                continue
            }

            switch status {
            case "completed":
                return try extractOutputURL(from: taskData)
            case "failed":
                let errMsg = (taskData["error"] as? String) ?? "Generation failed"
                throw APIError.generationFailed(errMsg)
            default:
                // "created", "processing", etc.
                try await Task.sleep(nanoseconds: Constants.Polling.intervalNanoseconds)
            }
        }

        throw APIError.timeout
    }

    private func extractOutputURL(from taskData: [String: Any]) throws -> URL {
        // outputs can be a string URL or an array of URLs
        if let outputs = taskData["outputs"] as? [String],
           let first = outputs.first,
           let url = URL(string: first) {
            return url
        }
        if let output = taskData["outputs"] as? String,
           let url = URL(string: output) {
            return url
        }
        // Fallback: check "output" key (some models)
        if let output = taskData["output"] as? String,
           let url = URL(string: output) {
            return url
        }
        throw APIError.invalidResponse("Cannot parse output URL from WaveSpeed response")
    }

    // MARK: - Download result

    private func downloadImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response, data: data)
        guard let image = UIImage(data: data) else {
            throw APIError.invalidResponse("Downloaded data is not a valid image")
        }
        return image
    }

    // MARK: - Helpers

    private func addHeaders(to request: inout URLRequest) {
        request.setValue("Bearer \(apiKey)",  forHTTPHeaderField: "Authorization")
        request.setValue("application/json",  forHTTPHeaderField: "Content-Type")
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
