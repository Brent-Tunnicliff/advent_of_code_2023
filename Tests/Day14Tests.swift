// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day14Tests: XCTestCase {
    private let testData = """
        O....#....
        O.OO#....#
        .....##...
        OO.#O....O
        .O.....O#.
        O.#..O.#.#
        ..O..#O..O
        .......O..
        #....###..
        #OO..#....
        """

    func testPart1() async throws {
        // when
        let result = await Day14(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "136")
    }

    func testPart2() async throws {
        // when
        let result = await Day14(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "64")
    }
}
