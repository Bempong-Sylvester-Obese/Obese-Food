import FirebaseCore
import FirebaseFirestore
import Foundation

final class GamificationManager: ObservableObject {
    @Published var oexPoints: Int = 0
    @Published var currentLevel: String = "Beginner"
    @Published var achievements: [Achievement] = []
    @Published var dailyStreak: Int = 0
    @Published var weeklyGoal: Int = 5
    @Published var weeklyProgress: Int = 0

    private var errorHandler: ErrorHandler?
    private var currentUserID: String?
    private let userProgressKey = "user_progress"
    private var db: Firestore? {
        FirebaseApp.app() == nil ? nil : Firestore.firestore()
    }

    private let pointsPerFoodScan = 10
    private let pointsPerHealthyMeal = 25
    private let pointsPerDailyGoal = 50

    init() {}

    func setErrorHandler(_ errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
    }

    func handleAuthStateChange(userID: String?, shouldAutoSync: Bool) {
        currentUserID = userID

        guard let userID else {
            resetPublishedState()
            return
        }

        loadLocalProgress(for: userID)

        if shouldAutoSync {
            loadFromFirebase()
        }
    }

    // MARK: - Points Management

    func awardPointsForFoodScan() {
        oexPoints += pointsPerFoodScan
        updateLevel()
        checkAchievements()
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

    func recordFoodScan() {
        oexPoints += pointsPerFoodScan
        updateDailyStreakIfNeeded()
        updateWeeklyProgress()
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
        updateDailyStreakIfNeeded()
        saveUserProgress()
    }

    // MARK: - Goal Management

    func setWeeklyGoal(_ goal: Int) {
        weeklyGoal = max(goal, 1)
        if weeklyProgress > weeklyGoal {
            weeklyProgress = weeklyGoal
        }
        saveUserProgress()
    }

    func updateWeeklyProgress() {
        weeklyProgress += 1

        if weeklyProgress >= weeklyGoal {
            weeklyProgress = 0
            oexPoints += pointsPerDailyGoal
        }
    }

    // MARK: - Data Persistence

    private func saveUserProgress() {
        let progress = UserProgress(
            oexPoints: oexPoints,
            currentLevel: currentLevel,
            achievements: achievements,
            dailyStreak: dailyStreak,
            weeklyGoal: weeklyGoal,
            weeklyProgress: weeklyProgress,
            lastFoodScanDate: lastFoodScanDate
        )

        // Save locally
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: storageKey(for: currentUserID))
        }

        // Sync to Firebase
        if currentUserID != nil {
            syncToFirebase(progress)
        }
    }

    private func syncToFirebase(_ progress: UserProgress) {
        guard let userID = currentUserID, let db else { return }

        do {
            try db.collection("userProgress").document(userID).setData(from: progress)
        } catch {
            errorHandler?.handle(.firebaseError("Failed to sync gamification progress: \(error.localizedDescription)"))
        }
    }

    func loadFromFirebase() {
        guard let userID = currentUserID, let db else { return }

        db.collection("userProgress").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                self?.errorHandler?.handle(.firebaseError("Failed to load gamification progress: \(error.localizedDescription)"))
                return
            }

            if let document = document, document.exists {
                do {
                    let progress = try document.data(as: UserProgress.self)
                    DispatchQueue.main.async {
                        self?.apply(progress)
                    }
                } catch {
                    self?.errorHandler?.handle(.firebaseError("Failed to decode gamification progress: \(error.localizedDescription)"))
                }
            } else {
                self?.saveUserProgress()
            }
        }
    }

    private var lastFoodScanDate: Date?

    private func updateDailyStreakIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())

        guard let lastFoodScanDate else {
            dailyStreak = 1
            self.lastFoodScanDate = today
            return
        }

        let lastLoggedDay = Calendar.current.startOfDay(for: lastFoodScanDate)
        if Calendar.current.isDate(lastLoggedDay, inSameDayAs: today) {
            return
        }

        let dayDelta = Calendar.current.dateComponents([.day], from: lastLoggedDay, to: today).day ?? 0
        dailyStreak = dayDelta == 1 ? dailyStreak + 1 : 1
        self.lastFoodScanDate = today
    }

    private func loadLocalProgress(for userID: String) {
        guard let data = UserDefaults.standard.data(forKey: storageKey(for: userID)),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            resetPublishedState()
            return
        }

        apply(progress)
    }

    private func apply(_ progress: UserProgress) {
        oexPoints = progress.oexPoints
        currentLevel = progress.currentLevel
        achievements = progress.achievements
        dailyStreak = progress.dailyStreak
        weeklyGoal = max(progress.weeklyGoal, 1)
        weeklyProgress = progress.weeklyProgress
        lastFoodScanDate = progress.lastFoodScanDate

        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: storageKey(for: currentUserID))
        }
    }

    private func resetPublishedState() {
        oexPoints = 0
        currentLevel = "Beginner"
        achievements = []
        dailyStreak = 0
        weeklyGoal = 5
        weeklyProgress = 0
        lastFoodScanDate = nil
    }

    private func storageKey(for userID: String?) -> String {
        "\(userProgressKey)_\(userID ?? "signed_out")"
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
    let lastFoodScanDate: Date?
}
