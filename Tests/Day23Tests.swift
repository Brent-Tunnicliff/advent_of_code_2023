// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day23Tests: XCTestCase {
    private let testData = """
        #.#####################
        #.......#########...###
        #######.#########.#.###
        ###.....#.>.>.###.#.###
        ###v#####.#v#.###.#.###
        ###.>...#.#.#.....#...#
        ###v###.#.#.#########.#
        ###...#.#.#.......#...#
        #####.#.#.#######.#.###
        #.....#.#.#.......#...#
        #.#####.#.#.#########v#
        #.#...#...#...###...>.#
        #.#.#v#######v###.###v#
        #...#.>.#...>.>.#.###.#
        #####v#.#.###v#.#.###.#
        #.....#...#...#.#.#...#
        #.#########.###.#.#.###
        #...###...#...#...#.###
        ###.###.#.###v#####v###
        #...#...#.#.>.>.#.>.###
        #.###.###.#.###.#.#v###
        #.....###...###...#...#
        #####################.#
        """

    func testPart1() async throws {
        // when
        let result = await Day23(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "94")
    }

    func testPart2() async throws {
        // when
        let result = await Day23(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "154")
    }

    func testGetPathLengthsSlippery() async throws {
        // given
        let expectedResults = [94, 90, 86, 82, 82, 74].sorted()

        // when
        let results = await Day23(data: testData).getPathLengths(isSlippery: true).sorted()

        // then
        XCTAssertEqual(results.count, expectedResults.count, "Unexpected length")

        for (index, expectedResult) in expectedResults.enumerated() {
            let result = results[index]
            XCTAssertEqual(result, expectedResult, "Expected \(expectedResult) at index \(index), got \(result)")
        }
    }
}
