import Foundation

struct ObeseFood: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Int
    let fatContent: Double
    let sugarContent: Double
    let proteinContent: Double
    let description: String
    let imageUrl: String?
    
    init(id: UUID = UUID(), name: String, calories: Int, fatContent: Double, sugarContent: Double, proteinContent: Double, description: String, imageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.calories = calories
        self.fatContent = fatContent
        self.sugarContent = sugarContent
        self.proteinContent = proteinContent
        self.description = description
        self.imageUrl = imageUrl
    }
}
