// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day22Tests: XCTestCase {
    private let testData = """
        1,0,1~1,2,1
        0,0,2~2,0,2
        0,2,3~2,2,3
        0,0,4~0,2,4
        2,0,5~2,2,5
        0,1,6~2,1,6
        1,1,8~1,1,9
        """

    func testPart1() async throws {
        // when
        let result = await Day22(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "5")
    }

    func testPart2() async throws {
        // when
        let result = await Day22(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
