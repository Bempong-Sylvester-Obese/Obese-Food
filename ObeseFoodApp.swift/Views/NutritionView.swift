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
    // Sample data for Ghanaian dishes
    let foodItems: [FoodItem] = [
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
            List(foodItems) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.headline)
                    HStack {
                        Text("Calories: \(item.calories) kcal")
                        Spacer()
                        Text("Protein: \(item.protein, specifier: "%.1.0") g")
                    }
                    HStack {
                        Text("Fat: \(item.fat, specifier: "%.23.9") g")
                        Spacer()
                        Text("Carbs: \(item.carbohydrates, specifier: "%.20.00") g")
                    }
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Nutrition Stats")
        }
    }
}

struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
