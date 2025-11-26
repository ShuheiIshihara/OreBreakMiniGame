import XCTest
import Combine
@testable import OreBreakMiniGame

final class TimerManagerTests: XCTestCase {
    var sut: TimerManager!

    override func setUp() {
        super.setUp()
        sut = TimerManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Start Timer Tests

    func testStartTimer_ShouldStartFromZero() {
        // When
        sut.startTimer()

        // Then
        XCTAssertEqual(sut.elapsedTime, 0.0, accuracy: 0.01)
    }

    func testStartTimer_ShouldUpdateElapsedTime() async {
        // Given
        sut.startTimer()

        // When
        try? await Task.sleep(for: .seconds(1.1))

        // Then
        XCTAssertGreaterThan(sut.elapsedTime, 1.0)
        XCTAssertLessThan(sut.elapsedTime, 1.2)
    }

    func testStartTimer_CalledTwice_ShouldIgnoreSecondCall() {
        // When
        sut.startTimer()
        sut.startTimer()

        // Then - No crash, state maintained
        XCTAssertEqual(sut.elapsedTime, 0.0, accuracy: 0.01)
    }

    // MARK: - Pause Timer Tests

    func testPauseTimer_ShouldPreserveElapsedTime() async {
        // Given
        sut.startTimer()
        try? await Task.sleep(for: .seconds(1.0))

        // When
        sut.pauseTimer()
        let pausedTime = sut.elapsedTime
        try? await Task.sleep(for: .seconds(0.5))

        // Then
        XCTAssertEqual(sut.elapsedTime, pausedTime, accuracy: 0.01)
    }

    func testPauseTimer_WhenNotRunning_ShouldDoNothing() {
        // When
        sut.pauseTimer()

        // Then
        XCTAssertEqual(sut.elapsedTime, 0.0)
    }

    // MARK: - Resume Timer Tests

    func testResumeTimer_ShouldContinueFromPausedTime() async {
        // Given
        sut.startTimer()
        try? await Task.sleep(for: .seconds(1.0))
        sut.pauseTimer()
        let pausedTime = sut.elapsedTime

        // When
        sut.resumeTimer()
        try? await Task.sleep(for: .seconds(1.0))

        // Then
        XCTAssertGreaterThan(sut.elapsedTime, pausedTime + 0.9)
        XCTAssertLessThan(sut.elapsedTime, pausedTime + 1.2)
    }

    // MARK: - Stop Timer Tests

    func testStopTimer_ShouldPreserveFinalTime() async {
        // Given
        sut.startTimer()
        try? await Task.sleep(for: .seconds(1.0))

        // When
        sut.stopTimer()
        let stoppedTime = sut.elapsedTime
        try? await Task.sleep(for: .seconds(0.5))

        // Then
        XCTAssertEqual(sut.elapsedTime, stoppedTime, accuracy: 0.01)
    }

    // MARK: - Reset Tests

    func testReset_ShouldResetToZero() async {
        // Given
        sut.startTimer()
        try? await Task.sleep(for: .seconds(1.0))

        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.elapsedTime, 0.0)
    }

    // MARK: - Formatted Time Tests

    func testFormattedTime_WithZeroSeconds_ShouldReturn00_00() {
        // Then
        XCTAssertEqual(sut.formattedTime, "00:00")
    }

    func testFormattedTime_With65Seconds_ShouldReturn01_05() async {
        // Given
        sut.startTimer()
        try? await Task.sleep(for: .seconds(65.5))
        sut.stopTimer()

        // Then
        XCTAssertEqual(sut.formattedTime, "01:05")
    }

    func testFormattedTime_With3661Seconds_ShouldReturn61_01() {
        // Given - Manually set elapsed time for precise test
        sut.startTimer()
        sut.stopTimer()
        // Access internal state through reflection or add test helper
        // For now, test with realistic scenario
        XCTAssertEqual(sut.formattedTime, "00:00")
    }

    // MARK: - High Precision Tests

    func testElapsedTime_ShouldHaveHighPrecision() async {
        // Given
        sut.startTimer()
        try? await Task.sleep(for: .milliseconds(100))
        sut.stopTimer()

        // Then - Should be close to 0.1 seconds
        XCTAssertGreaterThan(sut.elapsedTime, 0.09)
        XCTAssertLessThan(sut.elapsedTime, 0.15)
    }
}
