import Foundation
import Combine
import FirebaseFirestore

class GamificationManager: ObservableObject {
    @Published var oexPoints: Int = 0
    @Published var currentLevel: String = "Beginner"
    @Published var achievements: [Achievement] = []
    @Published var dailyStreak: Int = 0
    @Published var weeklyGoal: Int = 0
    @Published var weeklyProgress: Int = 0
    
    private let db = Firestore.firestore()
    private var errorHandler: ErrorHandler?
    
    private let pointsPerFoodScan = 10
    private let pointsPerHealthyMeal = 25
    private let pointsPerDailyGoal = 50
    
    init() {
        loadUserProgress()
    }
    
    func setErrorHandler(_ errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
    }
    
    // MARK: - Points Management
    
    func awardPointsForFoodScan() {
        oexPoints += pointsPerFoodScan
        updateLevel()
        saveUserProgress()
    }
    
    func awardPointsForHealthyMeal() {
        oexPoints += pointsPerHealthyMeal
        updateLevel()
        checkAchievements()
        saveUserProgress()
    }
    
    func awardPointsForDailyGoal() {
        oexPoints += pointsPerDailyGoal
        updateLevel()
        checkAchievements()
        saveUserProgress()
    }
    
    // MARK: - Level System
    
    private func updateLevel() {
        switch oexPoints {
        case 0..<100:
            currentLevel = "Beginner"
        case 100..<500:
            currentLevel = "Healthy Eater"
        case 500..<1000:
            currentLevel = "Nutrition Expert"
        case 1000..<2000:
            currentLevel = "Wellness Champion"
        case 2000..<5000:
            currentLevel = "Health Master"
        default:
            currentLevel = "Nutrition Legend"
        }
    }
    
    // MARK: - Achievements
    
    private func checkAchievements() {
        // First Scan Achievement
        if oexPoints >= pointsPerFoodScan && !achievements.contains(where: { $0.id == "first_scan" }) {
            achievements.append(Achievement(
                id: "first_scan",
                title: "First Steps",
                description: "Completed your first food scan",
                icon: "camera",
                pointsAwarded: 0
            ))
        }
        
        // Healthy Eater Achievement
        if oexPoints >= 100 && !achievements.contains(where: { $0.id == "healthy_eater" }) {
            achievements.append(Achievement(
                id: "healthy_eater",
                title: "Healthy Eater",
                description: "Reached 100 Oex points",
                icon: "leaf",
                pointsAwarded: 0
            ))
        }
        
        // Nutrition Expert Achievement
        if oexPoints >= 500 && !achievements.contains(where: { $0.id == "nutrition_expert" }) {
            achievements.append(Achievement(
                id: "nutrition_expert",
                title: "Nutrition Expert",
                description: "Reached 500 Oex points",
                icon: "chart.bar",
                pointsAwarded: 0
            ))
        }
        
        // Streak Achievements
        if dailyStreak >= 7 && !achievements.contains(where: { $0.id == "week_streak" }) {
            achievements.append(Achievement(
                id: "week_streak",
                title: "Week Warrior",
                description: "7-day tracking streak",
                icon: "flame",
                pointsAwarded: 0
            ))
        }
    }
    
    // MARK: - Streak Management
    
    func updateDailyStreak() {
        // This would typically check if the user has logged food today
        // For now, we'll simulate streak updates
        dailyStreak += 1
        saveUserProgress()
    }
    
    // MARK: - Goal Management
    
    func setWeeklyGoal(_ goal: Int) {
        weeklyGoal = goal
        saveUserProgress()
    }
    
    func updateWeeklyProgress() {
        weeklyProgress += 1
        if weeklyProgress >= weeklyGoal {
            awardPointsForDailyGoal()
        }
        saveUserProgress()
    }
    
    // MARK: - Data Persistence
    
    private func saveUserProgress() {
        let progress = UserProgress(
            oexPoints: oexPoints,
            currentLevel: currentLevel,
            achievements: achievements,
            dailyStreak: dailyStreak,
            weeklyGoal: weeklyGoal,
            weeklyProgress: weeklyProgress
        )
        
        // Save locally
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: "user_progress")
        }
        
        // Sync to Firebase
        syncToFirebase(progress)
    }
    
    private func syncToFirebase(_ progress: UserProgress) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("userProgress").document(userId).setData(from: progress)
        } catch {
            errorHandler?.handle(.firebaseError("Failed to sync gamification progress: \(error.localizedDescription)"))
        }
    }
    
    func loadFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("userProgress").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                self?.errorHandler?.handle(.firebaseError("Failed to load gamification progress: \(error.localizedDescription)"))
                return
            }
            
            if let document = document, document.exists {
                do {
                    let progress = try document.data(as: UserProgress.self)
                    DispatchQueue.main.async {
                        self?.oexPoints = progress.oexPoints
                        self?.currentLevel = progress.currentLevel
                        self?.achievements = progress.achievements
                        self?.dailyStreak = progress.dailyStreak
                        self?.weeklyGoal = progress.weeklyGoal
                        self?.weeklyProgress = progress.weeklyProgress
                        
                        // Save locally as well
                        if let encoded = try? JSONEncoder().encode(progress) {
                            UserDefaults.standard.set(encoded, forKey: "user_progress")
                        }
                    }
                } catch {
                    self?.errorHandler?.handle(.firebaseError("Failed to decode gamification progress: \(error.localizedDescription)"))
                }
            }
        }
    }
    
    private func loadUserProgress() {
        guard let data = UserDefaults.standard.data(forKey: "user_progress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return
        }
        
        oexPoints = progress.oexPoints
        currentLevel = progress.currentLevel
        achievements = progress.achievements
        dailyStreak = progress.dailyStreak
        weeklyGoal = progress.weeklyGoal
        weeklyProgress = progress.weeklyProgress
    }
}

// MARK: - Supporting Models

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let pointsAwarded: Int
    let dateEarned: Date = Date()
}

struct UserProgress: Codable {
    let oexPoints: Int
    let currentLevel: String
    let achievements: [Achievement]
    let dailyStreak: Int
    let weeklyGoal: Int
    let weeklyProgress: Int
}
