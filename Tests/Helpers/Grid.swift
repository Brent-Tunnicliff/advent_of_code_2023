// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest
@testable import AdventOfCode

final class GridTests: XCTestCase {
    let testData = """
        ...1......
        .......2..
        1.........
        ..........
        ......2...
        .1........
        .........1
        ..........
        .......2..
        2...1.....
        """

    func testDescription() throws {
        // given
        let grid = TestGrid(dataForEnum: testData)

        // when
        let result = grid.description

        // then
        XCTAssertEqual(result, testData)
    }
}

private extension GridTests {
    private typealias TestGrid = Grid<Value>
    private enum Value: String, CustomStringConvertible, CaseIterable {
        case empty = "."
        case one = "1"
        case two = "2"

        var description: String {
            rawValue
        }
    }
}
