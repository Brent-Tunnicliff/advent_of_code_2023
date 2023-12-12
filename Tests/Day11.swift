// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day11Tests: XCTestCase {
    let testData = """
        ...#......
        .......#..
        #.........
        ..........
        ......#...
        .#........
        .........#
        ..........
        .......#..
        #...#.....
        """

    func testPart1() async throws {
        // when
        let result = await Day11(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "374")
    }

    func testPart2A() async throws {
        // given
        Day11.part2Input = 10

        // when
        let result = await Day11(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "1030")
    }

    func testPart2B() async throws {
        // given
        Day11.part2Input = 100

        // when
        let result = await Day11(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "8410")
    }
}
