import SwiftUI

struct HomeView: View {
    @EnvironmentObject var analyzer: FoodAnalyzer
    @EnvironmentObject var gamificationManager: GamificationManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var hasSavedCurrentAnalysis = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    imageSection
                    analysisSection
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Obese Food")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) { _ in
                hasSavedCurrentAnalysis = false
                analyzer.reset()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Food Recognition")
                .font(.title)
                .fontWeight(.bold)

            Text("Select a meal photo to classify one of the supported dishes for this MVP.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text(FoodCatalog.supportedFoodNames.joined(separator: " • "))
                .font(.caption)
                .foregroundColor(.green)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    private var imageSection: some View {
        Group {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320, maxHeight: 320)
                    .cornerRadius(16)
                    .shadow(radius: 8)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.12))
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 42))
                                .foregroundColor(.gray)
                            Text("No meal image selected")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Pick a clear photo with good lighting for the strongest result.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    )
            }
        }
    }

    @ViewBuilder
    private var analysisSection: some View {
        if let analysis = analyzer.latestAnalysis {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(analysis.foodName)
                            .font(.headline)
                        Text(analysis.formattedResult)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if hasSavedCurrentAnalysis {
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Text(analysis.reviewMessage)
                    .font(.subheadline)
                    .foregroundColor(analysis.isLowConfidence ? .orange : .secondary)

                if let nutrition = analysis.nutrition {
                    nutritionSummary(for: nutrition)
                    Text(nutrition.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("This prediction needs a manual selection before it can be saved with nutrition data.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                manualSelectionSection(isHighlighted: analysis.isLowConfidence || analysis.nutrition == nil)
            }
            .padding()
            .background(Color.blue.opacity(0.08))
            .cornerRadius(14)
        } else if let errorMessage = analyzer.lastErrorMessage {
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.08))
                .cornerRadius(12)
        }
    }

    private func manualSelectionSection(isHighlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isHighlighted ? "Choose a supported dish" : "Change the detected dish")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isHighlighted ? .orange : .primary)

            Text("If the classifier picked the wrong meal, choose the closest supported dish before saving.")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(FoodCatalog.supportedProfiles) { profile in
                Button(action: {
                    analyzer.applyManualSelection(profile.foodName)
                    hasSavedCurrentAnalysis = false
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.foodName)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("\(profile.calories) kcal • \(profile.protein, specifier: "%.0f")g protein")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                showImagePicker = true
            }) {
                Label("Select Image", systemImage: "photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            if selectedImage != nil {
                Button(action: analyzeSelectedImage) {
                    HStack {
                        if analyzer.isAnalyzing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "sparkles")
                        }

                        Text(analyzer.isAnalyzing ? "Analyzing..." : "Analyze Meal")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(analyzer.isAnalyzing)
            }

            if analyzer.latestAnalysis != nil {
                Button(action: saveCurrentAnalysis) {
                    Label(hasSavedCurrentAnalysis ? "Saved to History" : "Save to History", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(saveButtonEnabled ? Color.orange : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!saveButtonEnabled)

                Button(action: resetCurrentScan) {
                    Label("Start New Scan", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
            }
        }
    }

    private var saveButtonEnabled: Bool {
        guard let analysis = analyzer.latestAnalysis else { return false }
        return !hasSavedCurrentAnalysis && analysis.nutrition != nil
    }

    private func analyzeSelectedImage() {
        guard let image = selectedImage else { return }
        hasSavedCurrentAnalysis = false
        analyzer.analyzeFood(image: image)
    }

    private func saveCurrentAnalysis() {
        guard saveButtonEnabled,
              let userID = authManager.currentUser?.uid,
              let analysis = analyzer.latestAnalysis,
              let nutrition = analysis.nutrition else {
            return
        }

        let foodScan = FoodScan(
            userId: userID,
            foodName: analysis.foodName,
            confidence: analysis.confidence,
            calories: nutrition.calories,
            protein: nutrition.protein,
            fat: nutrition.fat,
            carbohydrates: nutrition.carbohydrates,
            sugar: nutrition.sugar,
            notes: nutrition.summary
        )

        dataManager.addFoodScan(foodScan)
        gamificationManager.recordFoodScan()
        hasSavedCurrentAnalysis = true
    }

    private func resetCurrentScan() {
        selectedImage = nil
        hasSavedCurrentAnalysis = false
        analyzer.reset()
    }

    private func nutritionSummary(for nutrition: FoodNutritionProfile) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(nutrition.servingSize)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                nutritionMetric(title: "Calories", value: "\(nutrition.calories)")
                nutritionMetric(title: "Protein", value: "\(nutrition.protein, specifier: "%.0f")g")
            }

            HStack {
                nutritionMetric(title: "Fat", value: "\(nutrition.fat, specifier: "%.0f")g")
                nutritionMetric(title: "Carbs", value: "\(nutrition.carbohydrates, specifier: "%.0f")g")
            }
        }
    }

    private func nutritionMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.white.opacity(0.7))
        .cornerRadius(8)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(FoodAnalyzer())
            .environmentObject(GamificationManager())
            .environmentObject(DataManager())
            .environmentObject(AuthenticationManager())
    }
}
