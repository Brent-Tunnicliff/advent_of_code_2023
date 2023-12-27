// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day24: AdventDay {
    var data: String

    private var hailstones: [Hailstone] {
        data.split(separator: "\n").reduce(into: [Hailstone]()) { partialResult, row in
            let split = row.split(separator: " @ ")
            precondition(split.count == 2)

            let extractValues: (any StringProtocol) -> [Int] = {
                let result = $0.split(separator: ", ").map { Int($0.trimmingCharacters(in: .whitespaces))! }
                precondition(result.count == 3)
                return result
            }

            let startValues = extractValues(split[0])
            let start = ThreeDimensionalCoordinates(x: startValues[0], y: startValues[1], z: startValues[2])
            let endValues = extractValues(split[1])
            let end = ThreeDimensionalCoordinates(
                x: start.x + endValues[0],
                y: start.y + endValues[1],
                z: start.z + endValues[2]
            )

            partialResult.append(Hailstone(from: start, to: end))
        }
    }

    private var testAreaValue: (from: Int, to: Int) {
        guard testsAreNotRunning else {
            return (7, 27)
        }

        return (200_000_000_000_000, 400_000_000_000_000)
    }

    private var testArea: Box<Coordinates> {
        let testAreaValue = self.testAreaValue
        return .init(
            bottomLeft: .init(x: testAreaValue.from, y: testAreaValue.from),
            bottomRight: .init(x: testAreaValue.from, y: testAreaValue.to),
            topLeft: .init(x: testAreaValue.to, y: testAreaValue.from),
            topRight: .init(x: testAreaValue.to, y: testAreaValue.to)
        )
    }

    func part1() async -> Any {
        let testArea = self.testArea
        let hailstones = self.hailstones.map {
            // Extend each line out so we can calculate intersections.
            $0.twoDimensionalLine.extending(within: testArea)
        }

        var hailstonesAlreadyCounted: [SimplifiedHailstone] = []
        var numberOfIntersectionsInTestArea = 0
        for hailstone in hailstones {
            for otherHailstone in hailstones.filter({ $0 != hailstone && !hailstonesAlreadyCounted.contains($0) }) {
                guard
                    let intersection = hailstone.overlaps(otherHailstone),
                    testArea.contains(intersection)
                else {
                    continue
                }

                numberOfIntersectionsInTestArea += 1
            }

            hailstonesAlreadyCounted.append(hailstone)
        }

        if testsAreNotRunning {
            precondition(numberOfIntersectionsInTestArea > 18543, "18543 is too low")
        }

        return numberOfIntersectionsInTestArea
    }

    func part2() async -> Any {
        "Not implemented"
    }
}

private typealias Hailstone = Line<ThreeDimensionalCoordinates>
private typealias SimplifiedHailstone = Line<Coordinates>
