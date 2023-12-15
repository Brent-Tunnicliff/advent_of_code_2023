// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day17Tests: XCTestCase {
    let testData = """
        MISSING
        """

    func testPart1() async throws {
        // when
        let result = await Day17(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "")
    }

    func testPart2() async throws {
        // when
        let result = await Day17(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
