// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest
@testable import AdventOfCode

final class CoordinatesTests: XCTestCase {
    func testLineExtending() async throws {
        // given
        let box = Box(
            bottomLeft: .init(x: 7, y: 7),
            bottomRight: .init(x: 27, y: 7),
            topLeft: .init(x: 7, y: 27),
            topRight: .init(x: 27, y: 27)
        )

        let testCases: [(line: Line<Coordinates>, expectedToResult: Coordinates)] = [
            (
                Line(
                    from: Coordinates(x: 16, y: 16),
                    to: Coordinates(x: 20, y: 20)
                ),
                Coordinates(x: 80, y: 80)
            ),
            (
                Line(
                    from: Coordinates(x: 19, y: 13),
                    to: Coordinates(x: 17, y: 14)
                ),
                Coordinates(x: -61, y: 53)
            ),
        ]

        for test in testCases {
            // when
            let result = test.line.extending(within: box)

            // then
            XCTAssertEqual(result.from, test.line.from, test.line.description)
            XCTAssertEqual(result.to.x, test.expectedToResult.x, test.line.description)
            XCTAssertEqual(result.to.y, test.expectedToResult.y, test.line.description)
        }
    }

    func testOverlapLine() async throws {
        // given
        let inputs: [CoordinatesOverlapLineInput] = [
            .init(
                lineOne: .init(from: .init(x: 2, y: 6), to: .init(x: 5, y: 1)),
                lineTwo: .init(from: .init(x: 4, y: 0), to: .init(x: 5, y: 5)),
                expectedResult: .init(x: 4, y: 2)
            ),
            .init(
                lineOne: .init(from: .init(x: 19, y: 13), to: .init(x: 17, y: 14)),
                lineTwo: .init(from: .init(x: 7, y: 7), to: .init(x: 27, y: 27)),
                expectedResult: nil
            ),
            .init(
                lineOne: .init(from: .init(x: 0, y: 0), to: .init(x: 48, y: 48)),
                lineTwo: .init(from: .init(x: 19, y: 13), to: .init(x: -21, y: 33)),
                expectedResult: .init(x: 15, y: 15)
            ),
        ]

        for input in inputs {
            // when
            let result = input.lineOne.overlaps(input.lineTwo)

            // then
            XCTAssertEqual(
                result,
                input.expectedResult,
                "Unexpected result for \(input.lineOne.description) and \(input.lineTwo.description)"
            )
        }
    }
}

private struct CoordinatesOverlapLineInput {
    let lineOne: Line<Coordinates>
    let lineTwo: Line<Coordinates>
    let expectedResult: Coordinates?
}
