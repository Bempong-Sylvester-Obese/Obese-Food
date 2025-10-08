import SwiftUI
import Firebase

@main
struct ObeseFoodApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var gamificationManager = GamificationManager()
    @StateObject private var foodAnalyzer = FoodAnalyzer()
    @StateObject private var dataManager = DataManager()
    @StateObject private var errorHandler = ErrorHandler()
    
    init() {
        FirebaseApp.configure()
        
        // Set up service connections
        authManager.setErrorHandler(errorHandler)
        dataManager.setErrorHandler(errorHandler)
        gamificationManager.setErrorHandler(errorHandler)
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
