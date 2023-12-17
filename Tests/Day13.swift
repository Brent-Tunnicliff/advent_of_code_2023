// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day13Tests: XCTestCase {
    let testData = """
        #.##..##.
        ..#.##.#.
        ##......#
        ##......#
        ..#.##.#.
        ..##..##.
        #.#.##.#.

        #...##..#
        #....#..#
        ..##..###
        #####.##.
        #####.##.
        ..##..###
        #....#..#
        """

    let expandedTestData = """
        #.##..##.
        ..#.##.#.
        ##......#
        ##......#
        ..#.##.#.
        ..##..##.
        #.#.##.#.

        #...##..#
        #....#..#
        ..##..###
        #####.##.
        #####.##.
        ..##..###
        #....#..#

        ##..#######..
        .#.####.#.#..
        .#.#..#..##.#
        ...#..#.##.#.
        #.#..#....##.
        #.#..#....##.
        ...#..#.##.#.
        .#.#..#..##.#
        .#.##.#.#.#..
        ##..#######..
        #.#.##.#.....
        #.....###..#.
        ###.....###.#
        ###.....###.#
        #.....###..#.
        #.#.##.#.....
        ##..#######..

        .##...#.#...#
        #######..#.#.
        #..#.######.#
        ....###..##.#
        ......##.....
        #..##..#...##
        #..####.#....
        ###.#..##....
        ............#
        #..#..#####.#
        #..#..#####.#

        .#.##.#...#..
        ...##...##.#.
        #.####.##.#.#
        #.####.##.###
        ...##...##.#.
        .#.##.#...#..
        ..........#..
        """

    func testPart1A() async throws {
        // when
        let result = await Day13(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "405")
    }

    func testPart1B() async throws {
        // when
        let result = await Day13(data: expandedTestData).part1()

        // then
        XCTAssertEqual(String(describing: result), "2709")
    }

    func testPart2() async throws {
        // when
        let result = await Day13(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
