// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day25Tests: XCTestCase {
    private let testData = """
        jqt: rhn xhk nvd
        rsh: frs pzl lsr
        xhk: hfx
        cmg: qnr nvd lhk bvb
        rhn: xhk bvb hfx
        bvb: xhk hfx
        pzl: lsr hfx nvd
        qnr: nvd
        ntq: jqt hfx bvb xhk
        nvd: lhk
        lsr: lhk
        rzs: qnr cmg lsr rsh
        frs: qnr lhk lsr
        """

    func testPart1() async throws {
        // when
        let result = await Day25(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "54")
    }

    func testPart2() async throws {
        // when
        let result = await Day25(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "")
    }
}
