import CoreML
import Foundation
import UIKit

struct FoodImageFeatures: Equatable {
    static let orderedFeatureNames = [
        "redMean",
        "greenMean",
        "blueMean",
        "redStd",
        "greenStd",
        "blueStd",
        "brightnessMean",
        "saturationMean",
        "warmPixelRatio",
        "darkPixelRatio",
        "greenPixelRatio",
        "brightPixelRatio",
    ]

    let redMean: Double
    let greenMean: Double
    let blueMean: Double
    let redStd: Double
    let greenStd: Double
    let blueStd: Double
    let brightnessMean: Double
    let saturationMean: Double
    let warmPixelRatio: Double
    let darkPixelRatio: Double
    let greenPixelRatio: Double
    let brightPixelRatio: Double

    var dictionary: [String: Double] {
        [
            "redMean": redMean,
            "greenMean": greenMean,
            "blueMean": blueMean,
            "redStd": redStd,
            "greenStd": greenStd,
            "blueStd": blueStd,
            "brightnessMean": brightnessMean,
            "saturationMean": saturationMean,
            "warmPixelRatio": warmPixelRatio,
            "darkPixelRatio": darkPixelRatio,
            "greenPixelRatio": greenPixelRatio,
            "brightPixelRatio": brightPixelRatio,
        ]
    }

    static func extract(from image: UIImage, sampleSize: Int = 48) throws -> FoodImageFeatures {
        guard let cgImage = image.cgImage else {
            throw FoodRecognitionError.invalidImage
        }

        let width = sampleSize
        let height = sampleSize
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw FoodRecognitionError.featureExtractionFailed("Could not create an sRGB color space.")
        }

        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let drawSucceeded = pixelData.withUnsafeMutableBytes { rawBuffer -> Bool in
            guard let baseAddress = rawBuffer.baseAddress else {
                return false
            }

            guard let context = CGContext(
                data: baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                return false
            }

            context.interpolationQuality = .medium
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }

        guard drawSucceeded else {
            throw FoodRecognitionError.featureExtractionFailed("Could not create a bitmap context for the selected image.")
        }

        var redSum = 0.0
        var greenSum = 0.0
        var blueSum = 0.0
        var redSquareSum = 0.0
        var greenSquareSum = 0.0
        var blueSquareSum = 0.0
        var brightnessSum = 0.0
        var saturationSum = 0.0
        var warmPixels = 0.0
        var darkPixels = 0.0
        var greenPixels = 0.0
        var brightPixels = 0.0
        var validPixels = 0.0

        for pixelIndex in stride(from: 0, to: pixelData.count, by: bytesPerPixel) {
            let alpha = Double(pixelData[pixelIndex + 3]) / 255.0
            guard alpha > 0.01 else { continue }

            let red = Double(pixelData[pixelIndex]) / 255.0
            let green = Double(pixelData[pixelIndex + 1]) / 255.0
            let blue = Double(pixelData[pixelIndex + 2]) / 255.0

            redSum += red
            greenSum += green
            blueSum += blue
            redSquareSum += red * red
            greenSquareSum += green * green
            blueSquareSum += blue * blue

            let maxChannel = max(red, green, blue)
            let minChannel = min(red, green, blue)
            let brightness = maxChannel
            let saturation = maxChannel > 0 ? (maxChannel - minChannel) / maxChannel : 0.0

            brightnessSum += brightness
            saturationSum += saturation

            if red > green + 0.05, green > blue, saturation > 0.2 {
                warmPixels += 1
            }
            if brightness < 0.25 {
                darkPixels += 1
            }
            if green > red + 0.05, green > blue, saturation > 0.2 {
                greenPixels += 1
            }
            if brightness > 0.75 {
                brightPixels += 1
            }

            validPixels += 1
        }

        guard validPixels > 0 else {
            throw FoodRecognitionError.featureExtractionFailed("The image did not contain enough visible pixels to analyze.")
        }

        let redMean = redSum / validPixels
        let greenMean = greenSum / validPixels
        let blueMean = blueSum / validPixels
        let redVariance = max((redSquareSum / validPixels) - (redMean * redMean), 0)
        let greenVariance = max((greenSquareSum / validPixels) - (greenMean * greenMean), 0)
        let blueVariance = max((blueSquareSum / validPixels) - (blueMean * blueMean), 0)

        return FoodImageFeatures(
            redMean: redMean,
            greenMean: greenMean,
            blueMean: blueMean,
            redStd: sqrt(redVariance),
            greenStd: sqrt(greenVariance),
            blueStd: sqrt(blueVariance),
            brightnessMean: brightnessSum / validPixels,
            saturationMean: saturationSum / validPixels,
            warmPixelRatio: warmPixels / validPixels,
            darkPixelRatio: darkPixels / validPixels,
            greenPixelRatio: greenPixels / validPixels,
            brightPixelRatio: brightPixels / validPixels
        )
    }
}

struct FoodModelPrediction: Equatable {
    let foodName: String
    let confidence: Double
    let classProbabilities: [String: Double]
}

enum FoodRecognitionError: LocalizedError {
    case invalidImage
    case featureExtractionFailed(String)
    case missingModel(String)
    case invalidPrediction

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The selected image could not be prepared for analysis."
        case .featureExtractionFailed(let message):
            return message
        case .missingModel(let modelName):
            return "The bundled CoreML model \(modelName) could not be found."
        case .invalidPrediction:
            return "The food classifier returned an invalid prediction."
        }
    }
}

final class FoodRecognitionModel {
    static let modelName = "BaselineFoodClassifier"

    private let model: MLModel

    init(model: MLModel? = nil) throws {
        self.model = try model ?? Self.loadModel()
    }

    func predict(image: UIImage) throws -> FoodModelPrediction {
        let features = try FoodImageFeatures.extract(from: image)
        return try predict(features: features)
    }

    func predict(features: FoodImageFeatures) throws -> FoodModelPrediction {
        let featureDictionary = features.dictionary.reduce(into: [String: Any]()) { partialResult, element in
            partialResult[element.key] = NSNumber(value: element.value)
        }

        let provider = try MLDictionaryFeatureProvider(dictionary: featureDictionary)
        let output = try model.prediction(from: provider)

        let predictedFood = Self.predictedLabel(from: output)
        let probabilities = Self.predictedProbabilities(from: output)
        let confidence = probabilities[predictedFood] ?? probabilities.values.max() ?? 0

        guard !predictedFood.isEmpty else {
            throw FoodRecognitionError.invalidPrediction
        }

        return FoodModelPrediction(
            foodName: FoodCatalog.normalizedFoodName(from: predictedFood),
            confidence: confidence,
            classProbabilities: probabilities
        )
    }

    private static func loadModel() throws -> MLModel {
        if let compiledURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") {
            return try MLModel(contentsOf: compiledURL)
        }

        guard let rawModelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodel") else {
            throw FoodRecognitionError.missingModel(modelName)
        }

        let compiledURL = try MLModel.compileModel(at: rawModelURL)
        return try MLModel(contentsOf: compiledURL)
    }

    private static func predictedLabel(from output: MLFeatureProvider) -> String {
        for key in ["foodName", "classLabel", "target"] {
            if let label = output.featureValue(for: key)?.stringValue {
                return label
            }
        }

        return ""
    }

    private static func predictedProbabilities(from output: MLFeatureProvider) -> [String: Double] {
        for key in ["classProbability", "foodNameProbability", "targetProbability", "classLabelProbs"] {
            guard let dictionary = output.featureValue(for: key)?.dictionaryValue else { continue }

            let rawScores = dictionary.reduce(into: [String: Double]()) { partialResult, entry in
                if let label = entry.key as? String, let value = entry.value as? Double {
                    partialResult[label] = value
                } else if let label = entry.key as? String, let number = entry.value as? NSNumber {
                    partialResult[label] = number.doubleValue
                }
            }

            let total = rawScores.values.reduce(0, +)
            if total > 1 {
                return rawScores.mapValues { $0 / total }
            }

            return rawScores
        }

        let fallbackLabel = predictedLabel(from: output)
        return fallbackLabel.isEmpty ? [:] : [fallbackLabel: 1]
    }
}
