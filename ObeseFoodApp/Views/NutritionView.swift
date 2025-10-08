import SwiftUI

// Model representing a food item with nutrition statistics
struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int       // in kcal
    let protein: Double     // in grams
    let fat: Double         // in grams
    let carbohydrates: Double // in grams
    let description: String
}

struct NutritionView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var gamificationManager: GamificationManager
    
    // Sample data for Ghanaian dishes (fallback when no scans available)
    private let sampleFoodItems: [FoodItem] = [
        FoodItem(
            name: "Jollof Rice",
            calories: 350,
            protein: 8,
            fat: 10,
            carbohydrates: 50,
            description: "A popular dish made with rice, tomatoes, and spices, offering a balanced mix of carbs and moderate protein."
        ),
        FoodItem(
            name: "Waakye",
            calories: 400,
            protein: 12,
            fat: 8,
            carbohydrates: 60,
            description: "A hearty combination of rice and beans, rich in fiber and protein, ideal for sustained energy."
        ),
        FoodItem(
            name: "Banku and Tilapia",
            calories: 500,
            protein: 25,
            fat: 15,
            carbohydrates: 55,
            description: "Banku, a fermented corn and cassava dough paired with grilled tilapia, delivers high protein and essential fatty acids."
        ),
        FoodItem(
            name: "Fufu and Light Soup",
            calories: 450,
            protein: 20,
            fat: 10,
            carbohydrates: 70,
            description: "Fufu made from cassava and plantains served with a nutrient-rich light soup, providing ample carbohydrates and protein."
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Gamification Stats Header
                VStack(spacing: 12) {
                    HStack {
                        VStack {
                            Text("\(gamificationManager.oexPoints)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Oex Points")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text(gamificationManager.currentLevel)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Current Level")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Food History or Sample Data
                if dataManager.foodScanHistory.isEmpty {
                    // Show sample foods when no scan history
                    List(sampleFoodItems) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name)
                                .font(.headline)
                            HStack {
                                Text("Calories: \(item.calories) kcal")
                                Spacer()
                                Text("Protein: \(item.protein, specifier: "%.1f") g")
                            }
                            HStack {
                                Text("Fat: \(item.fat, specifier: "%.1f") g")
                                Spacer()
                                Text("Carbs: \(item.carbohydrates, specifier: "%.1f") g")
                            }
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .navigationTitle("Sample Foods")
                } else {
                    // Show user's food scan history
                    List(dataManager.foodScanHistory) { scan in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(scan.foodName)
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(scan.confidence * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if let calories = scan.calories {
                                Text("Calories: \(calories) kcal")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                if let protein = scan.protein {
                                    Text("Protein: \(protein, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if let fat = scan.fat {
                                    Text("Fat: \(fat, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if let carbs = scan.carbohydrates {
                                    Text("Carbs: \(carbs, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                            }
                            
                            Text(scan.timestamp, style: .date)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .navigationTitle("Your Food History")
                }
            }
        }
    }
}

struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
