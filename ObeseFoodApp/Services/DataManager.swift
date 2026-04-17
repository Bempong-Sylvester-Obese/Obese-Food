import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

/// Centralized data management for the Obese Food app
/// Handles both local storage and Firebase synchronization
final class DataManager: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var foodScanHistory: [FoodScan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var errorHandler: ErrorHandler?
    private var currentUserID: String?
    private var currentUserName: String?
    private var currentUserEmail: String?

    // Local storage keys
    private let userProfileKey = "user_profile"
    private let foodHistoryKey = "food_scan_history"
    private var db: Firestore? {
        FirebaseApp.app() == nil ? nil : Firestore.firestore()
    }

    init() {
        if FirebaseApp.app() != nil, let currentUser = Auth.auth().currentUser {
            handleAuthStateChange(
                userID: currentUser.uid,
                displayName: currentUser.displayName,
                email: currentUser.email,
                shouldAutoSync: AppSettings.autoSyncEnabled
            )
        }
    }

    func setErrorHandler(_ errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
    }

    func handleAuthStateChange(
        userID: String?,
        displayName: String?,
        email: String?,
        shouldAutoSync: Bool
    ) {
        currentUserID = userID
        currentUserName = displayName
        currentUserEmail = email

        guard let userID else {
            clearPublishedState()
            return
        }

        loadLocalData(for: userID)
        ensureLocalProfileSeed(for: userID, displayName: displayName, email: email)

        if shouldAutoSync {
            syncAllData()
        }
    }

    // MARK: - User Profile Management

    func saveUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveLocalUserProfile(profile)
        if currentUserID != nil {
            syncUserProfileToFirebase(profile)
        }
    }

    private func saveLocalUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: storageKey(for: userProfileKey, userID: profile.id))
        }
    }

    private func loadLocalUserProfile(for userID: String) -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey(for: userProfileKey, userID: userID)) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    private func syncUserProfileToFirebase(_ profile: UserProfile) {
        guard let db else { return }
        do {
            try db.collection("userProfiles").document(profile.id).setData(from: profile)
        } catch {
            errorHandler?.handle(.firebaseError("Failed to sync user profile: \(error.localizedDescription)"))
        }
    }

    func loadUserProfileFromFirebase() {
        guard let userID = currentUserID, let db else { return }

        isLoading = true
        db.collection("userProfiles").document(userID).getDocument { [weak self] document, error in
            defer {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }

            if let error = error {
                self?.errorHandler?.handle(.firebaseError("Failed to load user profile: \(error.localizedDescription)"))
                return
            }

            if let document = document, document.exists {
                do {
                    let profile = try document.data(as: UserProfile.self)
                    DispatchQueue.main.async {
                        self?.userProfile = profile
                        self?.saveLocalUserProfile(profile)
                    }
                } catch {
                    self?.errorHandler?.handle(.firebaseError("Failed to decode user profile: \(error.localizedDescription)"))
                }
            } else if let profile = self?.makeDefaultProfile(for: userID) {
                DispatchQueue.main.async {
                    self?.saveUserProfile(profile)
                }
            }
        }
    }

    // MARK: - Food Scan History

    func addFoodScan(_ scan: FoodScan) {
        foodScanHistory.insert(scan, at: 0) // Add to beginning
        saveLocalFoodHistory()
        if currentUserID != nil {
            syncFoodScanToFirebase(scan)
        }
    }

    private func saveLocalFoodHistory() {
        if let encoded = try? JSONEncoder().encode(foodScanHistory) {
            UserDefaults.standard.set(encoded, forKey: storageKey(for: foodHistoryKey, userID: currentUserID))
        }
    }

    private func loadLocalFoodHistory(for userID: String) -> [FoodScan] {
        guard let data = UserDefaults.standard.data(forKey: storageKey(for: foodHistoryKey, userID: userID)) else { return [] }
        return (try? JSONDecoder().decode([FoodScan].self, from: data)) ?? []
    }

    private func syncFoodScanToFirebase(_ scan: FoodScan) {
        guard let db else { return }
        do {
            try db.collection("foodScans").document(scan.id).setData(from: scan)
        } catch {
            errorHandler?.handle(.firebaseError("Failed to sync food scan: \(error.localizedDescription)"))
        }
    }

    func loadFoodScanHistoryFromFirebase() {
        guard let userID = currentUserID, let db else { return }

        isLoading = true
        db.collection("foodScans")
            .whereField("userId", isEqualTo: userID)
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .getDocuments { [weak self] snapshot, error in
                defer {
                    DispatchQueue.main.async {
                        self?.isLoading = false
                    }
                }

                if let error = error {
                    self?.errorHandler?.handle(.firebaseError("Failed to load food history: \(error.localizedDescription)"))
                    return
                }

                let scans = snapshot?.documents.compactMap { document in
                    try? document.data(as: FoodScan.self)
                } ?? []

                DispatchQueue.main.async {
                    self?.foodScanHistory = scans
                    self?.saveLocalFoodHistory()
                }
            }
    }

    // MARK: - Local Data Loading

    private func loadLocalData(for userID: String) {
        userProfile = loadLocalUserProfile(for: userID)
        foodScanHistory = loadLocalFoodHistory(for: userID)
    }

    // MARK: - Data Sync

    func syncAllData() {
        guard currentUserID != nil else { return }
        loadUserProfileFromFirebase()
        loadFoodScanHistoryFromFirebase()
    }

    func clearLocalData() {
        UserDefaults.standard.removeObject(forKey: storageKey(for: userProfileKey, userID: currentUserID))
        UserDefaults.standard.removeObject(forKey: storageKey(for: foodHistoryKey, userID: currentUserID))
        userProfile = nil
        foodScanHistory = []
    }

    private func ensureLocalProfileSeed(for userID: String, displayName: String?, email: String?) {
        guard userProfile == nil, let profile = makeDefaultProfile(for: userID, displayName: displayName, email: email) else {
            return
        }

        userProfile = profile
        saveLocalUserProfile(profile)
    }

    private func makeDefaultProfile(for userID: String, displayName: String? = nil, email: String? = nil) -> UserProfile? {
        let resolvedEmail = email ?? currentUserEmail
        guard let resolvedEmail else { return nil }

        let fallbackName = resolvedEmail.components(separatedBy: "@").first ?? "Obese Food User"
        let resolvedName = displayName ?? currentUserName ?? fallbackName

        return UserProfile(
            id: userID,
            name: resolvedName.isEmpty ? fallbackName : resolvedName,
            email: resolvedEmail
        )
    }

    private func clearPublishedState() {
        userProfile = nil
        foodScanHistory = []
    }

    private func storageKey(for baseKey: String, userID: String?) -> String {
        "\(baseKey)_\(userID ?? "signed_out")"
    }
}

// MARK: - Data Models

struct UserProfile: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let age: Int?
    let weight: Double?
    let height: Double?
    let gender: String?
    let dietaryPreferences: [String]
    let dailyCalorieGoal: Int
    let activityLevel: String
    let healthGoals: String
    let profileImageURL: String?
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        age: Int? = nil,
        weight: Double? = nil,
        height: Double? = nil,
        gender: String? = nil,
        dietaryPreferences: [String] = [],
        dailyCalorieGoal: Int = 2000,
        activityLevel: String = "Moderate",
        healthGoals: String = "Maintain weight",
        profileImageURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.age = age
        self.weight = weight
        self.height = height
        self.gender = gender
        self.dietaryPreferences = dietaryPreferences
        self.dailyCalorieGoal = dailyCalorieGoal
        self.activityLevel = activityLevel
        self.healthGoals = healthGoals
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct FoodScan: Codable, Identifiable {
    let id: String
    let userId: String
    let foodName: String
    let confidence: Double
    let calories: Int?
    let protein: Double?
    let fat: Double?
    let carbohydrates: Double?
    let sugar: Double?
    let imageURL: String?
    let timestamp: Date
    let location: String?
    let notes: String?
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        foodName: String,
        confidence: Double,
        calories: Int? = nil,
        protein: Double? = nil,
        fat: Double? = nil,
        carbohydrates: Double? = nil,
        sugar: Double? = nil,
        imageURL: String? = nil,
        timestamp: Date = Date(),
        location: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.foodName = foodName
        self.confidence = confidence
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbohydrates = carbohydrates
        self.sugar = sugar
        self.imageURL = imageURL
        self.timestamp = timestamp
        self.location = location
        self.notes = notes
    }
}
