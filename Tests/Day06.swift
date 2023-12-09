// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day06Tests: XCTestCase {
    private let testData = """
        Time:      7  15   30
        Distance:  9  40  200
        """

    func testPart1() async throws {
        // when
        let result = Day06(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "288")
    }

    func testPart2() async throws {
        // when
        let result = Day06(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
