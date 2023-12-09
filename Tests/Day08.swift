// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day08Tests: XCTestCase {
    private let testData = """
        RL

        AAA = (BBB, CCC)
        BBB = (DDD, EEE)
        CCC = (ZZZ, GGG)
        DDD = (DDD, DDD)
        EEE = (EEE, EEE)
        GGG = (GGG, GGG)
        ZZZ = (ZZZ, ZZZ)
        """

    func testPart1() async throws {
        // when
        let result = await Day08(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "2")
    }

    func testPart2() async throws {
        // when
        let result = await Day08(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
