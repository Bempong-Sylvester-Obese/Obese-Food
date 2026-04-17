import XCTest
@testable import ObeseFoodApp

final class GamificationManagerTests: XCTestCase {
    func testRecordFoodScanAwardsPointsAndAchievement() {
        let manager = GamificationManager()
        manager.handleAuthStateChange(userID: "gamification-tests-\(UUID().uuidString)", shouldAutoSync: false)

        manager.recordFoodScan()

        XCTAssertEqual(manager.oexPoints, 10)
        XCTAssertEqual(manager.dailyStreak, 1)
        XCTAssertEqual(manager.weeklyProgress, 1)
        XCTAssertTrue(manager.achievements.contains(where: { $0.id == "first_scan" }))
    }

    func testWeeklyGoalBonusResetsProgress() {
        let manager = GamificationManager()
        manager.handleAuthStateChange(userID: "weekly-goal-tests-\(UUID().uuidString)", shouldAutoSync: false)
        manager.setWeeklyGoal(1)

        manager.recordFoodScan()

        XCTAssertEqual(manager.oexPoints, 60)
        XCTAssertEqual(manager.weeklyProgress, 0)
    }
}
