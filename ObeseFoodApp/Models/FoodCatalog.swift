import Foundation

struct FoodNutritionProfile: Identifiable, Codable, Equatable {
    let id: String
    let foodName: String
    let servingSize: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbohydrates: Double
    let sugar: Double
    let summary: String

    init(
        foodName: String,
        servingSize: String,
        calories: Int,
        protein: Double,
        fat: Double,
        carbohydrates: Double,
        sugar: Double,
        summary: String
    ) {
        self.id = foodName
        self.foodName = foodName
        self.servingSize = servingSize
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbohydrates = carbohydrates
        self.sugar = sugar
        self.summary = summary
    }
}

enum FoodCatalog {
    static let unknownFoodName = "Unknown Food"

    static let supportedProfiles: [FoodNutritionProfile] = [
        FoodNutritionProfile(
            foodName: "Jollof Rice",
            servingSize: "1 plate",
            calories: 420,
            protein: 9,
            fat: 14,
            carbohydrates: 63,
            sugar: 6,
            summary: "Tomato-based rice dish with a higher carbohydrate load and moderate fat."
        ),
        FoodNutritionProfile(
            foodName: "Waakye",
            servingSize: "1 bowl",
            calories: 460,
            protein: 14,
            fat: 11,
            carbohydrates: 71,
            sugar: 4,
            summary: "Rice and beans dish with better protein and fiber balance than plain rice meals."
        ),
        FoodNutritionProfile(
            foodName: "Banku and Tilapia",
            servingSize: "1 serving",
            calories: 510,
            protein: 29,
            fat: 16,
            carbohydrates: 56,
            sugar: 2,
            summary: "Fermented corn and cassava dough paired with grilled fish for a stronger protein profile."
        ),
        FoodNutritionProfile(
            foodName: "Fufu and Light Soup",
            servingSize: "1 bowl",
            calories: 480,
            protein: 21,
            fat: 12,
            carbohydrates: 68,
            sugar: 5,
            summary: "Dense starch base served with soup, leading to a higher energy meal with moderate protein."
        ),
    ]

    static let supportedFoodNames: [String] = supportedProfiles.map(\.foodName)

    static func profile(for foodName: String) -> FoodNutritionProfile? {
        supportedProfiles.first { $0.foodName.caseInsensitiveCompare(foodName) == .orderedSame }
    }

    static func normalizedFoodName(from candidate: String) -> String {
        profile(for: candidate)?.foodName ?? candidate
    }
}
