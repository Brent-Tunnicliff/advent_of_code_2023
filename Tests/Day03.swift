// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day03Tests: XCTestCase {
    private let testData = """
        467..114..
        ...*......
        ..35..633.
        ......#...
        617*......
        .....+.58.
        ..592.....
        ......755.
        ...$.*....
        .664.598..
        """

    func testPart1() throws {
        // when
        let result = Day03(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "4361")
    }

    func testPart2() throws {
        XCTFail("Not implemented")
    }
}
