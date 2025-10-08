import Foundation
import SwiftUI

/// Centralized error handling for the Obese Food app
class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showAlert = false
    
    func handle(_ error: AppError) {
        DispatchQueue.main.async {
            self.currentError = error
            self.showAlert = true
        }
    }
    
    func handle(_ error: Error) {
        let appError = AppError.from(error)
        handle(appError)
    }
    
    func clearError() {
        currentError = nil
        showAlert = false
    }
}

/// App-specific error types
enum AppError: LocalizedError, Identifiable {
    case networkError(String)
    case authenticationError(String)
    case foodAnalysisError(String)
    case firebaseError(String)
    case validationError(String)
    case unknownError(String)
    
    var id: String {
        switch self {
        case .networkError(let message):
            return "network_\(message)"
        case .authenticationError(let message):
            return "auth_\(message)"
        case .foodAnalysisError(let message):
            return "food_\(message)"
        case .firebaseError(let message):
            return "firebase_\(message)"
        case .validationError(let message):
            return "validation_\(message)"
        case .unknownError(let message):
            return "unknown_\(message)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .foodAnalysisError(let message):
            return "Food Analysis Error: \(message)"
        case .firebaseError(let message):
            return "Firebase Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .unknownError(let message):
            return "Error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .authenticationError:
            return "Please check your credentials and try again."
        case .foodAnalysisError:
            return "Please try taking another photo with better lighting."
        case .firebaseError:
            return "Please try again later or contact support if the problem persists."
        case .validationError:
            return "Please check your input and try again."
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        // Convert common errors to app-specific errors
        if let urlError = error as? URLError {
            return .networkError(urlError.localizedDescription)
        }
        
        // Firebase errors
        let errorDescription = error.localizedDescription
        if errorDescription.contains("network") || errorDescription.contains("internet") {
            return .networkError(errorDescription)
        } else if errorDescription.contains("auth") || errorDescription.contains("password") {
            return .authenticationError(errorDescription)
        } else {
            return .unknownError(errorDescription)
        }
    }
}

/// Error alert view modifier
struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorHandler.showAlert) {
                Button("OK") {
                    errorHandler.clearError()
                }
            } message: {
                if let error = errorHandler.currentError {
                    Text(error.errorDescription ?? "An unknown error occurred")
                }
            }
    }
}

extension View {
    func withErrorHandling(_ errorHandler: ErrorHandler) -> some View {
        self.modifier(ErrorAlertModifier(errorHandler: errorHandler))
    }
}
