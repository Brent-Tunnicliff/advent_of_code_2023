// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest
@testable import AdventOfCode

final class GridTests: XCTestCase {
    private let testData = """
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
        // when
        let result = TestGrid(data: testData).description

        // then
        XCTAssertEqual(result, testData)
    }

    func testBottomLeft() throws {
        // when
        let result = TestGrid(data: testData).bottomLeft

        // then
        XCTAssertEqual(result.x, 0)
        XCTAssertEqual(result.y, 9)
    }

    func testBottomRight() throws {
        // when
        let result = TestGrid(data: testData).bottomRight

        // then
        XCTAssertEqual(result.x, 9)
        XCTAssertEqual(result.y, 9)
    }

    func testTopLeft() throws {
        // when
        let result = TestGrid(data: testData).topLeft

        // then
        XCTAssertEqual(result.x, 0)
        XCTAssertEqual(result.y, 0)
    }

    func testTopRight() throws {
        // when
        let result = TestGrid(data: testData).topRight

        // then
        XCTAssertEqual(result.x, 9)
        XCTAssertEqual(result.y, 0)
    }

    func testGetCoordinatesEastInvalid() throws {
        // when
        let result = TestGrid(data: testData).getCoordinates(from: .init(x: 9, y: 9), direction: .east)

        // then
        XCTAssertNil(result)
    }

    func testGetCoordinatesEastValid() throws {
        // when
        let result = TestGrid(data: testData).getCoordinates(from: .init(x: 0, y: 0), direction: .east)

        // then
        XCTAssertEqual(result?.x, 1)
        XCTAssertEqual(result?.y, 0)
    }

    func testGetCoordinatesNorthInvalid() throws {
        // when
        let result = TestGrid(data: testData).getCoordinates(from: .init(x: 0, y: 0), direction: .north)

        // then
        XCTAssertNil(result)
    }

    func testGetCoordinatesNorthValid() throws {
        // when
        let result = TestGrid(data: testData).getCoordinates(from: .init(x: 9, y: 9), direction: .north)

        // then
        XCTAssertEqual(result?.x, 9)
        XCTAssertEqual(result?.y, 8)
    }

    func testGetCoordinatesSouthInvalid() throws {
        // when
        let result = TestGrid(data: testData).getCoordinates(from: .init(x: 9, y: 9), direction: .south)

        // then
        XCTAssertNil(result)
    }

    func testGetCoordinatesSouthValid() throws {
        // when
        let result = TestGrid(data: testData).getCoordinates(from: .init(x: 0, y: 0), direction: .south)

        // then
        XCTAssertEqual(result?.x, 0)
        XCTAssertEqual(result?.y, 1)
    }

    func testGetCoordinatesWestInvalid() throws {
        // when
        let result = TestGrid(data: testData).getCoordinates(from: .init(x: 0, y: 0), direction: .west)

        // then
        XCTAssertNil(result)
    }

    func testGetCoordinatesWest() throws {
        // when
        let result = TestGrid(data: testData).getCoordinates(from: .init(x: 9, y: 9), direction: .west)

        // then
        XCTAssertEqual(result?.x, 8)
        XCTAssertEqual(result?.y, 9)
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
