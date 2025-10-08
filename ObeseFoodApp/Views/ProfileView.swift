import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var gamificationManager: GamificationManager
    @EnvironmentObject var dataManager: DataManager
    @State private var profileImage: UIImage? = UIImage(systemName: "person.circle.fill")
    @State private var showImagePicker = false
    @State private var showEditProfile = false
    @State private var showNutritionGoals = false
    @State private var showAchievements = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Image
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.green, lineWidth: 3))
                            .onTapGesture {
                                showImagePicker = true
                            }
                    }
                    
                    // User Info
                    VStack(spacing: 4) {
                        Text(authManager.currentUser?.displayName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authManager.currentUser?.email ?? "user@example.com")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top)
                
                // Gamification Stats
                VStack(spacing: 16) {
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
                
                // Profile Options
                VStack(spacing: 12) {
                    ProfileOptionRow(icon: "person.circle", title: "Edit Profile", action: {
                        showEditProfile = true
                    })
                    ProfileOptionRow(icon: "chart.bar", title: "Nutrition Goals", action: {
                        showNutritionGoals = true
                    })
                    ProfileOptionRow(icon: "trophy", title: "Achievements", action: {
                        showAchievements = true
                    })
                    ProfileOptionRow(icon: "gear", title: "Settings", action: {
                        showSettings = true
                    })
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    authManager.signOut()
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Sign Out")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showNutritionGoals) {
                NutritionGoalsView()
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
