// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day16Tests: XCTestCase {
    private let testData = #"""
        .|...\....
        |.-.\.....
        .....|-...
        ........|.
        ..........
        .........\
        ..../.\\..
        .-.-/..|..
        .|....-|.\
        ..//.|....
        """#

    func testPart1() async throws {
        // when
        let result = await Day16(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "46")
    }

    func testPart2() async throws {
        // when
        let result = await Day16(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "51")
    }
}
