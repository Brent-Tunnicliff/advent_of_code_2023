// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day15Tests: XCTestCase {
    let testData = """
        rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
        """

    func testPart1() async throws {
        // when
        let result = await Day15(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "1320")
    }

    func testPart2() async throws {
        // when
        let result = await Day15(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "145")
    }
}
