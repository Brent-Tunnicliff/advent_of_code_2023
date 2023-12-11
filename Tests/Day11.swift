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

    func testPart2() async throws {
        // when
        let result = await Day11(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }

    func testExpanded() {
        // given
        let grid = Day11(data: testData).getGrid()
        let expectedResult = """
            ....#........
            .........#...
            #............
            .............
            .............
            ........#....
            .#...........
            ............#
            .............
            .............
            .........#...
            #....#.......
            """

        // when
        grid.expanded()

        // then
        XCTAssertEqual(grid.description, expectedResult)
    }
}
