import XCTest
import UIKit
@testable import OreBreakMiniGame

final class HapticFeedbackManagerTests: XCTestCase {
    var sut: HapticFeedbackManager!

    override func setUp() {
        super.setUp()
        sut = HapticFeedbackManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Prepare Tests

    func testPrepare_ShouldSetIsPreparedToTrue() {
        // When
        sut.prepare()

        // Then
        XCTAssertTrue(sut.isPrepared)
    }

    func testPrepare_CalledTwice_ShouldOnlyPrepareOnce() {
        // When
        sut.prepare()
        sut.prepare()

        // Then
        XCTAssertTrue(sut.isPrepared)
    }

    // MARK: - Provide Feedback Tests

    func testProvideFeedback_WithoutPrepare_ShouldNotCrash() {
        // When/Then - Should not crash
        sut.provideFeedback(.light)
        sut.provideFeedback(.medium)
        sut.provideFeedback(.success)

        // Passes if no crash occurs
        XCTAssertTrue(true)
    }

    func testProvideFeedback_AfterPrepare_ShouldNotCrash() {
        // Given
        sut.prepare()

        // When/Then - Should not crash
        sut.provideFeedback(.light)
        sut.provideFeedback(.medium)
        sut.provideFeedback(.success)

        // Passes if no crash occurs
        XCTAssertTrue(true)
    }

    // MARK: - Cleanup Tests

    func testCleanup_ShouldResetIsPrepared() {
        // Given
        sut.prepare()

        // When
        sut.cleanup()

        // Then
        XCTAssertFalse(sut.isPrepared)
    }

    func testCleanup_CalledTwice_ShouldNotCrash() {
        // Given
        sut.prepare()

        // When/Then
        sut.cleanup()
        sut.cleanup()

        // Should not crash
        XCTAssertFalse(sut.isPrepared)
    }

    // MARK: - Lifecycle Tests

    func testLifecycle_PrepareProvideFeedbackCleanup_ShouldWorkCorrectly() {
        // When
        sut.prepare()
        XCTAssertTrue(sut.isPrepared)

        sut.provideFeedback(.light)
        sut.provideFeedback(.medium)

        sut.cleanup()
        XCTAssertFalse(sut.isPrepared)
    }

    // MARK: - Feedback Type Tests

    func testHapticFeedbackType_ShouldHaveAllRequiredCases() {
        // Given/Then
        let light: HapticFeedbackType = .light
        let medium: HapticFeedbackType = .medium
        let success: HapticFeedbackType = .success

        // Should compile and not crash
        XCTAssertTrue(true)
    }
}
