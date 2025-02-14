import SwiftUI

struct ProfileView: View {
    @State private var username: String = "Sylvester Bempong"
    @State private var email: String = "Sylvesterobese@example.com"
    @State private var profileImage: UIImage? = UIImage(systemName: "person.circle.fill")
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .padding()
                        .onTapGesture {
                            showImagePicker = true
                        }
                }
                
                Text(username)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    // Handle logout action
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
