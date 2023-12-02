import XCTest

@testable import AdventOfCode

final class Day01Tests: XCTestCase {
    func testPart1() throws {
        // given
        let testData = """
            1abc2
            pqr3stu8vwx
            a1b2c3d4e5f
            treb7uchet
            """

        // when
        let result = Day01(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "142")
    }

    func testPart2() throws {
        // given
        let testData = """
            two1nine
            eightwothree
            abcone2threexyz
            xtwone3four
            4nineeightseven2
            zoneight234
            7pqrstsixteen
            """

        // when
        let result = Day01(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "281")
    }
}
