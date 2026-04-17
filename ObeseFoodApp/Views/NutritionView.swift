import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var gamificationManager: GamificationManager

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
                    List {
                        Section(header: Text("Supported Dishes")) {
                            ForEach(FoodCatalog.supportedProfiles) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(item.foodName)
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
                                    Text(item.summary)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        Section {
                            Text("Your saved meal scans will appear here after you analyze and save them from the Scan tab.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Nutrition Guide")
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

                            HStack {
                                if let calories = scan.calories {
                                    Text("Calories: \(calories) kcal")
                                        .font(.subheadline)
                                }

                                if let sugar = scan.sugar {
                                    Spacer()
                                    Text("Sugar: \(sugar, specifier: "%.1f")g")
                                        .font(.caption)
                                }
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

                            if let notes = scan.notes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
            .environmentObject(DataManager())
            .environmentObject(GamificationManager())
    }
}
