import XCTest
@testable import OreBreakMiniGame

final class RandomProviderTests: XCTestCase {

    // MARK: - SystemRandomProvider Tests

    func testSystemRandomProvider_ShouldReturnValueBetween0And1() {
        // Given
        let sut = SystemRandomProvider()

        // When
        let value = sut.random()

        // Then
        XCTAssertGreaterThanOrEqual(value, 0.0)
        XCTAssertLessThanOrEqual(value, 1.0)
    }

    func testSystemRandomProvider_ShouldReturnDifferentValues() {
        // Given
        let sut = SystemRandomProvider()

        // When
        let value1 = sut.random()
        let value2 = sut.random()
        let value3 = sut.random()

        // Then - At least one should be different (with very high probability)
        XCTAssertTrue(value1 != value2 || value2 != value3 || value1 != value3)
    }

    // MARK: - MockRandomProvider Tests

    func testMockRandomProvider_ShouldReturnFixedValue() {
        // Given
        let fixedValue = 0.05
        let sut = MockRandomProvider(fixedValue: fixedValue)

        // When
        let value1 = sut.random()
        let value2 = sut.random()

        // Then
        XCTAssertEqual(value1, fixedValue)
        XCTAssertEqual(value2, fixedValue)
    }

    func testMockRandomProvider_WithZero_ShouldReturnZero() {
        // Given
        let sut = MockRandomProvider(fixedValue: 0.0)

        // When
        let value = sut.random()

        // Then
        XCTAssertEqual(value, 0.0)
    }

    func testMockRandomProvider_WithOne_ShouldReturnOne() {
        // Given
        let sut = MockRandomProvider(fixedValue: 1.0)

        // When
        let value = sut.random()

        // Then
        XCTAssertEqual(value, 1.0)
    }

    // MARK: - Protocol Conformance Tests

    func testRandomProviderProtocol_SystemProvider_ShouldConform() {
        // Given
        let provider: RandomProvider = SystemRandomProvider()

        // When
        let value = provider.random()

        // Then
        XCTAssertGreaterThanOrEqual(value, 0.0)
        XCTAssertLessThanOrEqual(value, 1.0)
    }

    func testRandomProviderProtocol_MockProvider_ShouldConform() {
        // Given
        let provider: RandomProvider = MockRandomProvider(fixedValue: 0.5)

        // When
        let value = provider.random()

        // Then
        XCTAssertEqual(value, 0.5)
    }
}
