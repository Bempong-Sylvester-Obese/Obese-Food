import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode

    @State private var autoSyncEnabled = AppSettings.autoSyncEnabled
    @State private var showClearDataAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sync")) {
                    Toggle("Auto Sync After Sign In", isOn: $autoSyncEnabled)
                        .onChange(of: autoSyncEnabled) { newValue in
                            AppSettings.autoSyncEnabled = newValue
                        }

                    Text("When enabled, profile, meal history, and points refresh automatically after sign in.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Data Management")) {
                    Button("Sync Now") {
                        dataManager.syncAllData()
                    }

                    Button("Clear Local Data") {
                        showClearDataAlert = true
                    }
                    .foregroundColor(.orange)
                }

                Section(header: Text("MVP Scope")) {
                    Text("This recovery build focuses on authentication, photo-based meal analysis for supported dishes, nutrition history, and profile sync.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Advanced exports, account deletion, and support links can be added after the MVP flow is stable.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

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
            .alert("Clear Local Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    dataManager.clearLocalData()
                }
            } message: {
                Text("This removes cached profile and meal history from this device. Your Firebase data stays intact.")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DataManager())
    }
}
