import XCTest

@testable import AdventOfCode

final class Day01Tests: XCTestCase {
    var challenge: Day01!

    // Smoke test data provided in the challenge question
    let testData = """
        1abc2
        pqr3stu8vwx
        a1b2c3d4e5f
        treb7uchet
        """

    override func setUp() {
        challenge = Day01(data: testData)
    }

    func testPart1() throws {
        let result = challenge.part1()
        XCTAssertEqual(String(describing: result), "142")
    }
}
