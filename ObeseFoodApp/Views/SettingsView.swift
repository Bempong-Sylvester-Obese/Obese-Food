import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var autoSyncEnabled = true
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // App Settings Section
                Section(header: Text("App Settings")) {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    Toggle("Auto Sync", isOn: $autoSyncEnabled)
                }
                
                // Data Section
                Section(header: Text("Data Management")) {
                    Button("Sync All Data") {
                        dataManager.syncAllData()
                    }
                    
                    Button("Clear Local Data") {
                        dataManager.clearLocalData()
                    }
                    .foregroundColor(.orange)
                    
                    Button("Export Data") {
                        exportData()
                    }
                }
                
                // Account Section
                Section(header: Text("Account")) {
                    Button("Change Password") {
                        // TODO: Implement password change
                    }
                    
                    Button("Delete Account") {
                        showDeleteAccountAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                // Support Section
                Section(header: Text("Support")) {
                    Button("Help & FAQ") {
                        // TODO: Open help documentation
                    }
                    
                    Button("Contact Support") {
                        // TODO: Open contact form
                    }
                    
                    Button("Rate App") {
                        // TODO: Open App Store rating
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Privacy Policy") {
                        // TODO: Open privacy policy
                    }
                    
                    Button("Terms of Service") {
                        // TODO: Open terms of service
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and will permanently remove all your data.")
            }
        }
    }
    
    private func exportData() {
        // TODO: Implement data export functionality
        print("Exporting user data...")
    }
    
    private func deleteAccount() {
        // TODO: Implement account deletion
        print("Deleting account...")
        // This would involve:
        // 1. Delete user data from Firebase
        // 2. Delete authentication account
        // 3. Clear local data
        // 4. Sign out user
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DataManager())
            .environmentObject(AuthenticationManager())
    }
}
