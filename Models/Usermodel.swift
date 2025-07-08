import Foundation
import Foodmodel

struct User: Identifiable, Codable {
    let id: UUID
    let name: String
    let age: Int
    let weight: Double
    let height: Double
    let gender: String
    let email: String
    let dietaryPreferences: [String]
    let favoriteFoods: [ObeseFood]
    let dailyCalorieIntake: Int
    let activityLevel: String
    let healthGoals: String
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        weight: Double,
        height: Double,
        gender: String,
        email: String,
        dietaryPreferences: [String] = [],
        favoriteFoods: [ObeseFood] = [],
        dailyCalorieIntake: Int,
        activityLevel: String,
        healthGoals: String
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.weight = weight
        self.height = height
        self.gender = gender
        self.email = email
        self.dietaryPreferences = dietaryPreferences
        self.favoriteFoods = favoriteFoods
        self.dailyCalorieIntake = dailyCalorieIntake
        self.activityLevel = activityLevel
        self.healthGoals = healthGoals
    }
}
