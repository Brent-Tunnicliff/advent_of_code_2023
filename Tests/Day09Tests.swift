// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day09Tests: XCTestCase {
    private let testData = """
        0 3 6 9 12 15
        1 3 6 10 15 21
        10 13 16 21 30 45
        """

    func testPart1() async throws {
        // when
        let result = await Day09(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "114")
    }

    func testPart2() async throws {
        // when
        let result = await Day09(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "2")
    }
}
