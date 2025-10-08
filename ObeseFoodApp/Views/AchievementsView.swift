import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var gamificationManager: GamificationManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                // Current Level Section
                Section(header: Text("Current Status")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(gamificationManager.currentLevel)
                                .font(.headline)
                            Text("Current Level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(gamificationManager.oexPoints)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Oex Points")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Achievements Section
                Section(header: Text("Achievements")) {
                    if gamificationManager.achievements.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "trophy")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No achievements yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Keep scanning food to earn your first achievement!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(gamificationManager.achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                }
                
                // Streak Section
                Section(header: Text("Streak")) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Daily Streak")
                        Spacer()
                        Text("\(gamificationManager.dailyStreak) days")
                            .fontWeight(.semibold)
                    }
                }
                
                // Weekly Goals Section
                Section(header: Text("Weekly Goals")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Weekly Goal")
                            Spacer()
                            Text("\(gamificationManager.weeklyGoal) scans")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Progress")
                            Spacer()
                            Text("\(gamificationManager.weeklyProgress) / \(gamificationManager.weeklyGoal)")
                                .fontWeight(.semibold)
                        }
                        
                        ProgressView(value: Double(gamificationManager.weeklyProgress), total: Double(gamificationManager.weeklyGoal))
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    }
                    .padding(.vertical, 4)
                }
                
                // Available Achievements
                Section(header: Text("Available Achievements")) {
                    AvailableAchievementRow(
                        icon: "camera.fill",
                        title: "First Steps",
                        description: "Complete your first food scan",
                        isUnlocked: gamificationManager.achievements.contains { $0.id == "first_scan" }
                    )
                    
                    AvailableAchievementRow(
                        icon: "leaf.fill",
                        title: "Healthy Eater",
                        description: "Reach 100 Oex points",
                        isUnlocked: gamificationManager.achievements.contains { $0.id == "healthy_eater" }
                    )
                    
                    AvailableAchievementRow(
                        icon: "chart.bar.fill",
                        title: "Nutrition Expert",
                        description: "Reach 500 Oex points",
                        isUnlocked: gamificationManager.achievements.contains { $0.id == "nutrition_expert" }
                    )
                    
                    AvailableAchievementRow(
                        icon: "flame.fill",
                        title: "Week Warrior",
                        description: "Maintain a 7-day tracking streak",
                        isUnlocked: gamificationManager.achievements.contains { $0.id == "week_streak" }
                    )
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(achievement.dateEarned, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AvailableAchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? .yellow : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
            .environmentObject(GamificationManager())
    }
}
