// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day11: AdventDay {
    var data: String

    func part1() async -> Any {
        let grid = getGrid()
        let whereToExpand = grid.getWhereToExpand()
        return getDistancesBetweenGalaxies(grid, with: 2, and: whereToExpand)
    }

    static var part2Input = 1_000_000
    func part2() async -> Any {
        let grid = getGrid()
        let whereToExpand = grid.getWhereToExpand()
        return getDistancesBetweenGalaxies(grid, with: Self.part2Input, and: whereToExpand)
    }

    private func getGrid() -> DayGrid {
        let grid = DayGrid(data: data)
        precondition(grid.description.trimmingCharacters(in: .newlines) == data.trimmingCharacters(in: .newlines))
        return grid
    }

    private func getDistancesBetweenGalaxies(
        _ grid: DayGrid,
        with padding: Int,
        and emptyIndexes: (x: [Int], y: [Int])
    ) -> Int {
        let galaxies = grid.values
            .filter { $0.value == .galaxy }
            .sorted(by: { $0.key < $1.key })

        let result = galaxies.reduce(into: 0) { partialResult, position in
            let filteredGalaxies = galaxies.filter {
                $0.key > position.key
            }

            for galaxy in filteredGalaxies {
                partialResult += getDistance(between: galaxy.key, and: position.key, with: padding, and: emptyIndexes)
            }
        }

        return result
    }

    private func getDistance(
        between origin: DayGrid.Coordinates,
        and destination: DayGrid.Coordinates,
        with padding: Int,
        and emptyIndexes: (x: [Int], y: [Int])
    ) -> Int {
        let xDifference = getDifference(between: origin.x, and: destination.x, with: padding, and: emptyIndexes.x)
        let yDifference = getDifference(between: origin.y, and: destination.y, with: padding, and: emptyIndexes.y)
        return xDifference + yDifference
    }

    private func getDifference(
        between origin: Int,
        and destination: Int,
        with padding: Int,
        and emptyIndexes: [Int]
    ) -> Int {
        let min = min(origin, destination)
        let max = max(origin, destination)
        let intersectingEmptyIndexes = (min...max).filter { emptyIndexes.contains($0) }
        return max - min + (intersectingEmptyIndexes.count * (padding - 1))
    }
}

private extension Day11 {
    typealias DayGrid = Grid<Value>

    enum Value: String, CustomStringConvertible, CaseIterable {
        case empty = "."
        case galaxy = "#"

        var description: String {
            self.rawValue
        }
    }
}

extension Grid where Value == Day11.Value {
    private var xLength: Int {
        values.filter { $0.key.y == 0 }.count
    }

    private var yLength: Int {
        values.filter { $0.key.x == 0 }.count
    }

    func getWhereToExpand() -> (x: [Int], y: [Int]) {
        let xIndexes = (0..<xLength).reduce(into: [Int]()) { partialResult, index in
            guard values.filter({ $0.key.x == index && $0.value == .empty }).count == xLength else {
                return
            }

            partialResult.append(index)
        }

        let yIndexes = (0..<yLength).reduce(into: [Int]()) { partialResult, index in
            guard values.filter({ $0.key.y == index && $0.value == .empty }).count == yLength else {
                return
            }

            partialResult.append(index)
        }

        return (xIndexes, yIndexes)
    }
}
