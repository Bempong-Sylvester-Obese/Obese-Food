import Foundation
import Vision
import UIKit

class AIRecognitionService {
    static let shared = AIRecognitionService()
    
    private init() {}
    
    func analyzeFoodImage(image: UIImage, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "InvalidImage", code: 400, userInfo: nil)))
            return
        }
        
        let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: ObeseFoodClassifier().model)) { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation], let bestResult = results.first else {
                completion(.failure(NSError(domain: "NoResults", code: 404, userInfo: nil)))
                return
            }
            
            let analysis: [String: Any] = [
                "foodName": bestResult.identifier,
                "confidence": bestResult.confidence
            ]
            completion(.success(analysis))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
}
