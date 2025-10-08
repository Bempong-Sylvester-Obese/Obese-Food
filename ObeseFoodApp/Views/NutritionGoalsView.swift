import SwiftUI

struct NutritionGoalsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var dailyCalorieGoal: String = "2000"
    @State private var proteinGoal: String = "150"
    @State private var carbGoal: String = "250"
    @State private var fatGoal: String = "65"
    @State private var waterGoal: String = "8"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Calorie Goals")) {
                    TextField("Daily Calorie Goal", text: $dailyCalorieGoal)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Macronutrient Goals (grams)")) {
                    TextField("Protein Goal", text: $proteinGoal)
                        .keyboardType(.decimalPad)
                    TextField("Carbohydrate Goal", text: $carbGoal)
                        .keyboardType(.decimalPad)
                    TextField("Fat Goal", text: $fatGoal)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Hydration")) {
                    TextField("Water Goal (glasses)", text: $waterGoal)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Tips")) {
                    Text("• Aim for a balanced diet with all macronutrients")
                    Text("• Stay hydrated throughout the day")
                    Text("• Adjust goals based on your activity level")
                    Text("• Consult a nutritionist for personalized advice")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .navigationTitle("Nutrition Goals")
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
                        saveGoals()
                    }
                }
            }
            .onAppear {
                loadCurrentGoals()
            }
        }
    }
    
    private func loadCurrentGoals() {
        if let profile = dataManager.userProfile {
            dailyCalorieGoal = String(profile.dailyCalorieGoal)
            // Set default macronutrient goals based on calorie goal
            let calories = profile.dailyCalorieGoal
            proteinGoal = String(Int(Double(calories) * 0.25 / 4)) // 25% of calories from protein
            carbGoal = String(Int(Double(calories) * 0.45 / 4))   // 45% of calories from carbs
            fatGoal = String(Int(Double(calories) * 0.30 / 9))    // 30% of calories from fat
        }
    }
    
    private func saveGoals() {
        guard let userId = Auth.auth().currentUser?.uid,
              let userEmail = authManager.currentUser?.email else { return }
        
        let updatedProfile = UserProfile(
            id: userId,
            name: dataManager.userProfile?.name ?? "",
            email: userEmail,
            age: dataManager.userProfile?.age,
            weight: dataManager.userProfile?.weight,
            height: dataManager.userProfile?.height,
            gender: dataManager.userProfile?.gender,
            dietaryPreferences: dataManager.userProfile?.dietaryPreferences ?? [],
            dailyCalorieGoal: Int(dailyCalorieGoal) ?? 2000,
            activityLevel: dataManager.userProfile?.activityLevel ?? "Moderate",
            healthGoals: dataManager.userProfile?.healthGoals ?? "Maintain weight",
            profileImageURL: dataManager.userProfile?.profileImageURL,
            createdAt: dataManager.userProfile?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        dataManager.saveUserProfile(updatedProfile)
        presentationMode.wrappedValue.dismiss()
    }
}

struct NutritionGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionGoalsView()
            .environmentObject(DataManager())
    }
}
