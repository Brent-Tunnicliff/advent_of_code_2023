// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day07Tests: XCTestCase {
    private let testData = """
        32T3K 765
        T55J5 684
        KK677 28
        KTJJT 220
        QQQJA 483
        """

    func testPart1() async throws {
        // when
        let result = Day07(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "6440")
    }

    func testPart2() async throws {
        // when
        let result = Day07(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "5905")
    }
}
