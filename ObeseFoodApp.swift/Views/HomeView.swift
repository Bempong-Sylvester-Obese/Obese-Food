import SwiftUI

struct HomeView: View {
    @StateObject private var analyzer = FoodAnalyzer()
    @StateObject private var gamificationManager = GamificationManager()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("Food Recognition")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Take a photo of your food to get nutritional insights")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Image Display
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "camera")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No image selected")
                                    .foregroundColor(.gray)
                            }
                        )
                }
                
                // Analysis Result
                if !analyzer.predictionResult.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Analysis Result")
                            .font(.headline)
                        
                        Text(analyzer.predictionResult)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Select Image")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    if selectedImage != nil {
                        Button(action: {
                            if let image = selectedImage {
                                analyzer.analyzeFood(image: image)
                                // Award points for food scan
                                gamificationManager.awardPointsForFoodScan()
                            }
                        }) {
                            HStack {
                                if analyzer.isAnalyzing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "magnifyingglass")
                                }
                                Text(analyzer.isAnalyzing ? "Analyzing..." : "Analyze Food")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(analyzer.isAnalyzing)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Obese Food")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
