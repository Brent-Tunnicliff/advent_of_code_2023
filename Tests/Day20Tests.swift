// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day20Tests: XCTestCase {
    func testPart1A() async throws {
        // given
        let testData = """
            broadcaster -> a, b, c
            %a -> b
            %b -> c
            %c -> inv
            &inv -> a
            """

        // when
        let result = await Day20(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "32000000")
    }

    func testPart1B() async throws {
        // given
        let testData = """
            broadcaster -> a
            %a -> inv, con
            &inv -> b
            %b -> con
            &con -> output
            """

        // when
        let result = await Day20(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "11687500")
    }

    func testPart2() async throws {
        // given
        let testData = """
            MISSING
            """

        // when
        let result = await Day20(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
