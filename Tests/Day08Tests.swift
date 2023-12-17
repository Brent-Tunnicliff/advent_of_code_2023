// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day08Tests: XCTestCase {
    func testPart1() async throws {
        // given
        let testData = """
            RL

            AAA = (BBB, CCC)
            BBB = (DDD, EEE)
            CCC = (ZZZ, GGG)
            DDD = (DDD, DDD)
            EEE = (EEE, EEE)
            GGG = (GGG, GGG)
            ZZZ = (ZZZ, ZZZ)
            """

        // when
        let result = await Day08(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "2")
    }

    func testPart2() async throws {
        // given
        let testData = """
            LR

            11A = (11B, XXX)
            11B = (XXX, 11Z)
            11Z = (11B, XXX)
            22A = (22B, XXX)
            22B = (22C, 22C)
            22C = (22Z, 22Z)
            22Z = (22B, 22B)
            XXX = (XXX, XXX)
            """

        // when
        let result = await Day08(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "6")
    }
}
