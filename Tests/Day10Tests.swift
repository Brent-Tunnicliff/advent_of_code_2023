// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import XCTest

@testable import AdventOfCode

final class Day10Tests: XCTestCase {
    func testPart1A() async throws {
        // given
        let testData = """
            .....
            .S-7.
            .|.|.
            .L-J.
            .....
            """

        // when
        let result = await Day10(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "4")
    }

    func testPart1B() async throws {
        // given
        let testData = """
            ..F7.
            .FJ|.
            SJ.L7
            |F--J
            LJ...
            """

        // when
        let result = await Day10(data: testData).part1()

        // then
        XCTAssertEqual(String(describing: result), "8")
    }

    func testPart2A() async throws {
        // given
        let testData = """
            ...........
            .S-------7.
            .|F-----7|.
            .||.....||.
            .||.....||.
            .|L-7.F-J|.
            .|..|.|..|.
            .L--J.L--J.
            ...........
            """

        // when
        let result = await Day10(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "4")
    }

    func testPart2B() async throws {
        // given
        let testData = """
            .F----7F7F7F7F-7....
            .|F--7||||||||FJ....
            .||.FJ||||||||L7....
            FJL7L7LJLJ||LJ.L-7..
            L--J.L7...LJS7F-7L7.
            ....F-J..F7FJ|L7L7L7
            ....L7.F7||L7|.L7L7|
            .....|FJLJ|FJ|F7|.LJ
            ....FJL-7.||.||||...
            ....L---J.LJ.LJLJ...
            """

        // when
        let result = await Day10(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "8")
    }

    func testPart2C() async throws {
        // given
        let testData = """
            FF7FSF7F7F7F7F7F---7
            L|LJ||||||||||||F--J
            FL-7LJLJ||||||LJL-77
            F--JF--7||LJLJ7F7FJ-
            L---JF-JLJ.||-FJLJJ7
            |F|F-JF---7F7-L7L|7|
            |FFJF7L7F-JF7|JL---7
            7-L-JL7||F7|L7F-7F7|
            L.L7LFJ|||||FJL7||LJ
            L7JLJL-JLJLJL--JLJ.L
            """

        // when
        let result = await Day10(data: testData).part2()

        // then
        XCTAssertEqual(String(describing: result), "10")
    }
}
