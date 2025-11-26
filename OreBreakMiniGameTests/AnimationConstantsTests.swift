import XCTest
@testable import OreBreakMiniGame

final class AnimationConstantsTests: XCTestCase {

    // MARK: - Destroy Duration Tests

    func testDestroyDuration_ShouldBe0Point4Seconds() {
        // Then
        XCTAssertEqual(AnimationConstants.destroyDuration, 0.4, accuracy: 0.001)
    }

    // MARK: - Diamond Drop Duration Tests

    func testDiamondDropDuration_ShouldBe1Point5Seconds() {
        // Then
        XCTAssertEqual(AnimationConstants.diamondDropDuration, 1.5, accuracy: 0.001)
    }

    // MARK: - Crack Transition Duration Tests

    func testCrackTransitionDuration_ShouldBe0Point15Seconds() {
        // Then
        XCTAssertEqual(AnimationConstants.crackTransitionDuration, 0.15, accuracy: 0.001)
    }

    // MARK: - Start Hint Fade Duration Tests

    func testStartHintFadeDuration_ShouldBe1Point0Second() {
        // Then
        XCTAssertEqual(AnimationConstants.startHintFadeDuration, 1.0, accuracy: 0.001)
    }

    // MARK: - Consistency Tests

    func testDestroyDuration_ShouldBePositive() {
        // Then
        XCTAssertGreaterThan(AnimationConstants.destroyDuration, 0.0)
    }

    func testDiamondDropDuration_ShouldBeLongerThanDestroyDuration() {
        // Then
        XCTAssertGreaterThan(
            AnimationConstants.diamondDropDuration,
            AnimationConstants.destroyDuration
        )
    }

    func testAllDurations_ShouldBeWithinReasonableRange() {
        // Given - Animation durations should be between 0.1s and 5.0s
        let minDuration: TimeInterval = 0.1
        let maxDuration: TimeInterval = 5.0

        // Then
        XCTAssertGreaterThan(AnimationConstants.destroyDuration, minDuration)
        XCTAssertLessThan(AnimationConstants.destroyDuration, maxDuration)

        XCTAssertGreaterThan(AnimationConstants.diamondDropDuration, minDuration)
        XCTAssertLessThan(AnimationConstants.diamondDropDuration, maxDuration)

        XCTAssertGreaterThan(AnimationConstants.crackTransitionDuration, minDuration)
        XCTAssertLessThan(AnimationConstants.crackTransitionDuration, maxDuration)

        XCTAssertGreaterThan(AnimationConstants.startHintFadeDuration, minDuration)
        XCTAssertLessThan(AnimationConstants.startHintFadeDuration, maxDuration)
    }

    // MARK: - Type Tests

    func testAllDurations_ShouldBeTimeInterval() {
        // Given
        let destroy: TimeInterval = AnimationConstants.destroyDuration
        let diamondDrop: TimeInterval = AnimationConstants.diamondDropDuration
        let crackTransition: TimeInterval = AnimationConstants.crackTransitionDuration
        let startHintFade: TimeInterval = AnimationConstants.startHintFadeDuration

        // Should compile - validates type correctness
        XCTAssertTrue(true)
    }
}
