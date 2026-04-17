import FirebaseCore
import SwiftUI

@main
struct ObeseFoodApp: App {
    @StateObject private var authManager: AuthenticationManager
    @StateObject private var gamificationManager: GamificationManager
    @StateObject private var foodAnalyzer: FoodAnalyzer
    @StateObject private var dataManager: DataManager
    @StateObject private var errorHandler: ErrorHandler

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let errorHandler = ErrorHandler()
        let authManager = AuthenticationManager()
        let gamificationManager = GamificationManager()
        let foodAnalyzer = FoodAnalyzer()
        let dataManager = DataManager()

        authManager.setErrorHandler(errorHandler)
        dataManager.setErrorHandler(errorHandler)
        gamificationManager.setErrorHandler(errorHandler)
        foodAnalyzer.setErrorHandler(errorHandler)

        _errorHandler = StateObject(wrappedValue: errorHandler)
        _authManager = StateObject(wrappedValue: authManager)
        _gamificationManager = StateObject(wrappedValue: gamificationManager)
        _foodAnalyzer = StateObject(wrappedValue: foodAnalyzer)
        _dataManager = StateObject(wrappedValue: dataManager)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(gamificationManager)
                .environmentObject(foodAnalyzer)
                .environmentObject(dataManager)
                .environmentObject(errorHandler)
                .withErrorHandling(errorHandler)
        }
    }
}
