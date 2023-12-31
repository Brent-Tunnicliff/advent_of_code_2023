// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day21Tests: XCTestCase {
    private let testData = """
        ...........
        .....###.#.
        .###.##..#.
        ..#.#...#..
        ....#.#....
        .##..S####.
        .##..#...#.
        .......##..
        .##.#.####.
        .##..##.##.
        ...........
        """

    func testPart1() async throws {
        // given
        Day21.part1Target = 6

        // when
        let result = await Day21(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "16")
    }

    func testPart2() async throws {
        // when
        let result = await Day21(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
