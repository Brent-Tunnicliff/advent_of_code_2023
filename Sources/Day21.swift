// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day21: AdventDay {
    var data: String

    static var part1Target = 64
    func part1() async -> Any {
        traverseGrid(totalSteps: Self.part1Target).count
    }

    func part2() async -> Any {
        "Not implemented"
    }

    private func traverseGrid(totalSteps: Int) -> [Coordinates] {
        let grid = getGrid()
        let startingPoint = grid.startingPoint

        let cache = Cache<Step, Set<Coordinates>>()
        var results: Set<Coordinates> = []

        for direction in CompassDirection.allCases {
            guard let position = grid.getNextGardenPlot(from: startingPoint, direction: direction) else {
                continue
            }

            results.formUnion(
                getLastPositions(
                    grid: grid,
                    cache: cache,
                    totalSteps: totalSteps,
                    step: .init(count: 1, from: position)
                )
            )
        }

        return Array(results)
    }

    private func getGrid() -> DayGrid {
        DayGrid(data: data)
    }

    private func getLastPositions(
        grid: DayGrid,
        cache: Cache<Step, Set<Coordinates>>,
        totalSteps: Int,
        step: Step
    ) -> Set<Coordinates> {
        if let cacheValue = cache[step] {
            return cacheValue
        }

        let nextCount = step.count + 1
        var results = Set<Coordinates>()

        for direction in CompassDirection.allCases {
            guard let position = grid.getNextGardenPlot(from: step.from, direction: direction) else {
                continue
            }

            guard nextCount != totalSteps else {
                results.insert(position)
                continue
            }

            results.formUnion(
                getLastPositions(
                    grid: grid,
                    cache: cache,
                    totalSteps: totalSteps,
                    step: .init(count: nextCount, from: position)
                )
            )
        }

        cache[step] = results
        return results
    }
}

// MARK: - Step

private struct Step {
    let count: Int
    let from: Coordinates
}

extension Step: Comparable {
    static func < (lhs: Step, rhs: Step) -> Bool {
        guard lhs.count == rhs.count else {
            return lhs.count < rhs.count
        }

        return lhs.from < rhs.from
    }
}

extension Step: Hashable {}

// MARK: - DayGrid

private typealias DayGrid = Grid<Coordinates, DayValue>

private extension DayGrid {
    var startingPoint: Coordinates {
        self.values.first(where: { $0.value == .startingPosition })!.key
    }

    func getNextGardenPlot(from: Coordinates, direction: CompassDirection) -> Coordinates? {
        guard
            let position = getCoordinates(from: from, direction: direction),
            self[position] != .rock
        else {
            return nil
        }

        return position
    }
}

// MARK: - DayValue

private enum DayValue: String, CaseIterable {
    case gardenPlot = "."
    case rock = "#"
    case startingPosition = "S"
}

extension DayValue: CustomStringConvertible {
    var description: String {
        rawValue
    }
}
