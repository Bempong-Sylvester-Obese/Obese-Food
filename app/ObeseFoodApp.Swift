import SwiftUI
import Firebase
import FirebaseStorage
import CoreML
import Vision

class FoodAnalyzer: ObservableObject {
    @Published var predictionResult: String = ""
    
    func analyzeFood(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: FoodRecognitionModel().model) else {
            predictionResult = "Model failed to load"
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                self.predictionResult = "No prediction found"
                return
            }
            
            DispatchQueue.main.async {
                self.predictionResult = "Predicted: \(topResult.identifier) with confidence \(topResult.confidence)"
            }
        }
        
        guard let ciImage = CIImage(image: image) else { return }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
}

struct ContentView: View {
    @StateObject private var analyzer = FoodAnalyzer()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            Text(analyzer.predictionResult)
                .padding()
            
            Button("Select Image") {
                showImagePicker = true
            }
            .padding()
            
            Button("Analyze") {
                if let image = selectedImage {
                    analyzer.analyzeFood(image: image)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

@main
struct ObeseFoodApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
