// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day17Tests: XCTestCase {
    private let testData = """
        2413432311323
        3215453535623
        3255245654254
        3446585845452
        4546657867536
        1438598798454
        4457876987766
        3637877979653
        4654967986887
        4564679986453
        1224686865563
        2546548887735
        4322674655533
        """

    func testPart1() async throws {
        // when
        let result = await Day17(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "102")
    }

    func testPart2() async throws {
        // when
        let result = await Day17(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
