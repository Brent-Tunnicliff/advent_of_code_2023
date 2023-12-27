// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day24Tests: XCTestCase {
    private let testData = """
        19, 13, 30 @ -2,  1, -2
        18, 19, 22 @ -1, -1, -2
        20, 25, 34 @ -2, -2, -4
        12, 31, 28 @ -1, -2, -1
        20, 19, 15 @  1, -5, -3
        """

    func testPart1() async throws {
        // when
        let result = await Day24(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "2")
    }

    func testPart2() async throws {
        // when
        let result = await Day24(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
