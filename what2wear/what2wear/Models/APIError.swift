import Foundation

enum APIError: LocalizedError {
    case missingAPIKey
    case unauthorized
    case serverError(Int, String?)
    case invalidResponse(String)
    case imageConversionFailed
    case baseImageMissing
    case generationFailed(String)
    case timeout
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Replicate API key not set. Open Constants.swift and paste your token from replicate.com/account/api-tokens."
        case .unauthorized:
            return "Invalid Replicate API key — double-check your token at replicate.com/account/api-tokens."
        case .serverError(let code, let body):
            let detail = body.flatMap { $0.isEmpty ? nil : String($0.prefix(200)) } ?? "no detail"
            return "Server error \(code): \(detail)"
        case .invalidResponse(let detail):
            return "Unexpected server response: \(detail)"
        case .imageConversionFailed:
            return "Could not compress the selected photo. Please try a different image."
        case .baseImageMissing:
            return "avatar.png is missing from Assets.xcassets. Add it and rebuild."
        case .generationFailed(let message):
            return "Generation failed: \(message)"
        case .timeout:
            return "The request timed out after 5 minutes. Check your network and try again."
        case .networkUnavailable:
            return "No internet connection. Check your Wi-Fi or cellular and try again."
        }
    }
}
