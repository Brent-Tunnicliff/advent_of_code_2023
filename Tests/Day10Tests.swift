// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day10Tests: XCTestCase {
    func testPart1A() async throws {
        // given
        let testData = """
            .....
            .S-7.
            .|.|.
            .L-J.
            .....
            """

        // when
        let result = await Day10(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "4")
    }

    func testPart1B() async throws {
        // given
        let testData = """
            ..F7.
            .FJ|.
            SJ.L7
            |F--J
            LJ...
            """

        // when
        let result = await Day10(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "8")
    }

    func testPart2() async throws {
        // given
        let testData = """
            MISSING
            """

        // when
        let result = await Day10(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
