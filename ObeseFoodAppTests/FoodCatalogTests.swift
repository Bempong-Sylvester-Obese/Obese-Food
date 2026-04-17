import XCTest
@testable import ObeseFoodApp

final class FoodCatalogTests: XCTestCase {
    func testLookupIsCaseInsensitive() {
        let profile = FoodCatalog.profile(for: "jollof rice")

        XCTAssertEqual(profile?.foodName, "Jollof Rice")
        XCTAssertEqual(profile?.calories, 420)
    }

    func testSupportedProfilesHaveNutritionValues() {
        XCTAssertFalse(FoodCatalog.supportedProfiles.isEmpty)

        for profile in FoodCatalog.supportedProfiles {
            XCTAssertGreaterThan(profile.calories, 0)
            XCTAssertGreaterThanOrEqual(profile.protein, 0)
            XCTAssertGreaterThanOrEqual(profile.fat, 0)
            XCTAssertGreaterThanOrEqual(profile.carbohydrates, 0)
            XCTAssertFalse(profile.summary.isEmpty)
        }
    }
}
