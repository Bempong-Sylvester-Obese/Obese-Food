import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var gender: String = "Male"
    @State private var activityLevel: String = "Moderate"
    @State private var healthGoals: String = "Maintain weight"
    @State private var dailyCalorieGoal: String = "2000"
    
    let genderOptions = ["Male", "Female", "Other"]
    let activityLevels = ["Sedentary", "Light", "Moderate", "Active", "Very Active"]
    let healthGoalsOptions = ["Lose weight", "Maintain weight", "Gain weight", "Build muscle"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.numberPad)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Health & Fitness")) {
                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(activityLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    Picker("Health Goals", selection: $healthGoals) {
                        ForEach(healthGoalsOptions, id: \.self) { goal in
                            Text(goal).tag(goal)
                        }
                    }
                    
                    TextField("Daily Calorie Goal", text: $dailyCalorieGoal)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        if let profile = dataManager.userProfile {
            name = profile.name
            age = profile.age.map(String.init) ?? ""
            weight = profile.weight.map { String(format: "%.1f", $0) } ?? ""
            height = profile.height.map(String.init) ?? ""
            gender = profile.gender ?? "Male"
            activityLevel = profile.activityLevel
            healthGoals = profile.healthGoals
            dailyCalorieGoal = String(profile.dailyCalorieGoal)
        } else if let user = authManager.currentUser {
            name = user.displayName ?? ""
        }
    }
    
    private func saveProfile() {
        guard let userId = authManager.currentUser?.uid,
              let userEmail = authManager.currentUser?.email else { return }
        
        let profile = UserProfile(
            id: userId,
            name: name,
            email: userEmail,
            age: Int(age),
            weight: Double(weight),
            height: Double(height),
            gender: gender,
            dietaryPreferences: dataManager.userProfile?.dietaryPreferences ?? [],
            dailyCalorieGoal: Int(dailyCalorieGoal) ?? 2000,
            activityLevel: activityLevel,
            healthGoals: healthGoals,
            profileImageURL: dataManager.userProfile?.profileImageURL,
            createdAt: dataManager.userProfile?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        dataManager.saveUserProfile(profile)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(DataManager())
            .environmentObject(AuthenticationManager())
    }
}
