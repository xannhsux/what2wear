import Foundation

enum APIError: LocalizedError {
    case missingAPIKey
    case unauthorized
    case serverError(Int, String?)
    case invalidResponse(String)
    case imageConversionFailed
    case generationFailed(String)
    case timeout
    case networkUnavailable
    case firebaseError(String)
    case notAuthenticated
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "WaveSpeed API key not set. Open Secrets.swift and paste your key from wavespeed.ai/accesskey."
        case .unauthorized:
            return "Invalid WaveSpeed API key — double-check your key at wavespeed.ai/accesskey."
        case .serverError(let code, let body):
            let detail = body.flatMap { $0.isEmpty ? nil : String($0.prefix(200)) } ?? "no detail"
            return "Server error \(code): \(detail)"
        case .invalidResponse(let detail):
            return "Unexpected server response: \(detail)"
        case .imageConversionFailed:
            return "Could not compress the selected photo. Please try a different image."
        case .generationFailed(let message):
            return "Generation failed: \(message)"
        case .timeout:
            return "The request timed out after 6 minutes. Check your network and try again."
        case .networkUnavailable:
            return "No internet connection. Check your Wi-Fi or cellular and try again."
        case .firebaseError(let message):
            return "Firebase error: \(message)"
        case .notAuthenticated:
            return "Not signed in. Please restart the app."
        case .itemNotFound:
            return "The requested item was not found."
        }
    }
}
