// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day12Tests: XCTestCase {
    let testData = """
        ???.### 1,1,3
        .??..??...?##. 1,1,3
        ?#?#?#?#?#?#?#? 1,3,1,6
        ????.#...#... 4,1,1
        ????.######..#####. 1,6,5
        ?###???????? 3,2,1
        """

    func testPart1() async throws {
        // when
        let result = await Day12(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "21")
    }

    func testPart2() async throws {
        // when
        let result = await Day12(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
