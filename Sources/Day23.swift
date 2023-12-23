// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day23: AdventDay {
    var data: String

    func part1() async -> Any {
        await getPathLengths().max()!
    }

    func part2() async -> Any {
        "Not implemented"
    }

    func getPathLengths() async -> [Int] {
        let grid = DayGrid(data: data)
        return await nextStep(
            from: grid.startingPosition,
            in: .south,
            towards: grid.endPosition,
            grid: grid,
            history: .init()
        )
    }

    private func nextStep(
        from coordinates: Coordinates,
        in direction: CompassDirection,
        towards destination: Coordinates,
        grid: DayGrid,
        history: History
    ) async -> [Int] {
        guard let position = grid.getCoordinates(from: coordinates, direction: direction) else {
            return []
        }

        guard !history.values.contains(position) else {
            return []
        }

        let newHistory = history.adding(coordinates: position)
        guard position != destination else {
            return [newHistory.values.count]
        }

        let directions: [CompassDirection] =
            switch grid[position]! {
            case .forest:
                preconditionFailure("Unexpected forrest")
            case .path:
                CompassDirection.allCases
            case .slopeEast:
                [.east]
            case .slopeNorth:
                [.north]
            case .slopeSouth:
                [.south]
            case .slopeWest:
                [.west]
            }

        return await withTaskGroup(of: [Int].self) { group in
            for direction in directions {
                group.addTask {
                    await nextStep(
                        from: position,
                        in: direction,
                        towards: destination,
                        grid: grid,
                        history: newHistory
                    )
                }
            }

            var results: [Int] = []
            for await result in group {
                results.append(contentsOf: result)
            }

            return results
        }
    }
}

// MARK: - DayGrid

// The grid never changes, so making it class to save memory use in recursive function.
private class DayGrid {
    let endPosition: Coordinates
    let startingPosition: Coordinates

    private let grid: Grid<Coordinates, Value>

    init(data: String) {
        let grid = Grid<Coordinates, Value>(data: data)
        let yCoordinates = grid.values.keys.map(\.y)
        let maxY = yCoordinates.max()!
        let minY = yCoordinates.min()!
        endPosition = grid.values.keys.filter { $0.y == maxY }.first(where: { grid[$0] == .path })!
        startingPosition = grid.values.keys.filter { $0.y == minY }.first(where: { grid[$0] == .path })!

        self.grid = grid
    }

    subscript(key: Coordinates) -> Value? {
        get {
            grid[key]
        }
    }

    func getCoordinates(from: Coordinates, direction: CompassDirection) -> Coordinates? {
        guard
            let coordinates = grid.getCoordinates(from: from, direction: direction),
            self[coordinates] != .forest
        else {
            return nil
        }

        return coordinates
    }
}

// MARK: - Value

private enum Value: String, CaseIterable {
    case forest = "#"
    case path = "."
    case slopeEast = ">"
    case slopeNorth = "^"
    case slopeSouth = "v"
    case slopeWest = "<"
}

extension Value: CustomStringConvertible {
    var description: String {
        rawValue
    }
}

// MARK: - History

private struct History {
    let values: [Coordinates]

    init(values: [Coordinates] = []) {
        self.values = values
    }

    func adding(coordinates: Coordinates) -> History {
        .init(values: values + [coordinates])
    }
}
