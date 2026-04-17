import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var gamificationManager: GamificationManager

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear(perform: refreshServicesForCurrentUser)
        .onChange(of: authManager.currentUser?.uid) { _ in
            refreshServicesForCurrentUser()
        }
        .onChange(of: authManager.isAuthenticated) { _ in
            refreshServicesForCurrentUser()
        }
    }

    private func refreshServicesForCurrentUser() {
        let currentUser = authManager.currentUser

        dataManager.handleAuthStateChange(
            userID: currentUser?.uid,
            displayName: currentUser?.displayName,
            email: currentUser?.email,
            shouldAutoSync: AppSettings.autoSyncEnabled
        )

        gamificationManager.handleAuthStateChange(
            userID: currentUser?.uid,
            shouldAutoSync: AppSettings.autoSyncEnabled
        )
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("Scan")
                }
            
            NutritionView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Nutrition")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}
