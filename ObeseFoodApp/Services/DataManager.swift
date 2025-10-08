import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

/// Centralized data management for the Obese Food app
/// Handles both local storage and Firebase synchronization
class DataManager: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var foodScanHistory: [FoodScan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var errorHandler: ErrorHandler?
    
    // Local storage keys
    private let userProfileKey = "user_profile"
    private let foodHistoryKey = "food_scan_history"
    
    init() {
        loadLocalData()
    }
    
    func setErrorHandler(_ errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
    }
    
    // MARK: - User Profile Management
    
    func saveUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveLocalUserProfile(profile)
        syncUserProfileToFirebase(profile)
    }
    
    private func saveLocalUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        }
    }
    
    private func loadLocalUserProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: userProfileKey) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    private func syncUserProfileToFirebase(_ profile: UserProfile) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("userProfiles").document(userId).setData(from: profile)
        } catch {
            errorHandler?.handle(.firebaseError("Failed to sync user profile: \(error.localizedDescription)"))
        }
    }
    
    func loadUserProfileFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("userProfiles").document(userId).getDocument { [weak self] document, error in
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
            }
        }
    }
    
    // MARK: - Food Scan History
    
    func addFoodScan(_ scan: FoodScan) {
        foodScanHistory.insert(scan, at: 0) // Add to beginning
        saveLocalFoodHistory()
        syncFoodScanToFirebase(scan)
    }
    
    private func saveLocalFoodHistory() {
        if let encoded = try? JSONEncoder().encode(foodScanHistory) {
            UserDefaults.standard.set(encoded, forKey: foodHistoryKey)
        }
    }
    
    private func loadLocalFoodHistory() -> [FoodScan] {
        guard let data = UserDefaults.standard.data(forKey: foodHistoryKey) else { return [] }
        return (try? JSONDecoder().decode([FoodScan].self, from: data)) ?? []
    }
    
    private func syncFoodScanToFirebase(_ scan: FoodScan) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("foodScans").document(scan.id).setData(from: scan)
        } catch {
            errorHandler?.handle(.firebaseError("Failed to sync food scan: \(error.localizedDescription)"))
        }
    }
    
    func loadFoodScanHistoryFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("foodScans")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .getDocuments { [weak self] snapshot, error in
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
    
    private func loadLocalData() {
        userProfile = loadLocalUserProfile()
        foodScanHistory = loadLocalFoodHistory()
    }
    
    // MARK: - Data Sync
    
    func syncAllData() {
        loadUserProfileFromFirebase()
        loadFoodScanHistoryFromFirebase()
    }
    
    func clearLocalData() {
        UserDefaults.standard.removeObject(forKey: userProfileKey)
        UserDefaults.standard.removeObject(forKey: foodHistoryKey)
        userProfile = nil
        foodScanHistory = []
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
