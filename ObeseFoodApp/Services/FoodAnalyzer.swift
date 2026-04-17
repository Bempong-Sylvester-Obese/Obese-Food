import Foundation
import UIKit

struct FoodAnalysis: Identifiable, Equatable {
    let id = UUID()
    let foodName: String
    let confidence: Double
    let nutrition: FoodNutritionProfile?
    let isLowConfidence: Bool
    let wasManuallyAdjusted: Bool
    let classProbabilities: [String: Double]

    var reviewMessage: String {
        if wasManuallyAdjusted {
            return "Using your selected food match."
        }

        if isLowConfidence {
            return "Confidence is low, so review the meal before saving it."
        }

        return "Confidence looks strong for this supported meal."
    }

    var formattedResult: String {
        let percentage = Int((confidence * 100).rounded())
        return "\(foodName) • \(percentage)% confidence"
    }
}

final class FoodAnalyzer: ObservableObject {
    @Published var predictionResult = ""
    @Published var isAnalyzing = false
    @Published var confidence = 0.0
    @Published var detectedFood = ""
    @Published var latestAnalysis: FoodAnalysis?
    @Published var lastErrorMessage: String?

    private var recognitionModel: FoodRecognitionModel?
    private var errorHandler: ErrorHandler?

    init() {
        setupModel()
    }

    func setErrorHandler(_ errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
    }

    func analyzeFood(image: UIImage) {
        isAnalyzing = true
        latestAnalysis = nil
        lastErrorMessage = nil
        predictionResult = "Analyzing your meal..."
        confidence = 0
        detectedFood = ""

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            do {
                guard let recognitionModel = self.recognitionModel else {
                    throw FoodRecognitionError.missingModel(FoodRecognitionModel.modelName)
                }

                let prediction = try recognitionModel.predict(image: image)
                let nutrition = FoodCatalog.profile(for: prediction.foodName)
                let isLowConfidence = prediction.foodName == FoodCatalog.unknownFoodName || prediction.confidence < 0.6 || nutrition == nil

                let analysis = FoodAnalysis(
                    foodName: nutrition?.foodName ?? prediction.foodName,
                    confidence: prediction.confidence,
                    nutrition: nutrition,
                    isLowConfidence: isLowConfidence,
                    wasManuallyAdjusted: false,
                    classProbabilities: prediction.classProbabilities
                )

                DispatchQueue.main.async {
                    self.apply(analysis)
                    self.isAnalyzing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    self.latestAnalysis = nil
                    self.predictionResult = "We couldn't analyze that image."
                    self.lastErrorMessage = error.localizedDescription
                    self.errorHandler?.handle(.foodAnalysisError(error.localizedDescription))
                }
            }
        }
    }

    func applyManualSelection(_ foodName: String) {
        guard let nutrition = FoodCatalog.profile(for: foodName) else { return }

        let analysis = FoodAnalysis(
            foodName: nutrition.foodName,
            confidence: max(latestAnalysis?.confidence ?? 0.35, 0.35),
            nutrition: nutrition,
            isLowConfidence: false,
            wasManuallyAdjusted: true,
            classProbabilities: latestAnalysis?.classProbabilities ?? [:]
        )

        apply(analysis)
    }

    func reset() {
        predictionResult = ""
        isAnalyzing = false
        confidence = 0
        detectedFood = ""
        latestAnalysis = nil
        lastErrorMessage = nil
    }

    private func setupModel() {
        do {
            recognitionModel = try FoodRecognitionModel()
        } catch {
            recognitionModel = nil
            lastErrorMessage = error.localizedDescription
        }
    }

    private func apply(_ analysis: FoodAnalysis) {
        latestAnalysis = analysis
        detectedFood = analysis.foodName
        confidence = analysis.confidence
        predictionResult = analysis.formattedResult
        lastErrorMessage = nil
    }
}
