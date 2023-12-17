// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day16: AdventDay {
    var data: String

    private var grid: DayGrid {
        DayGrid(dataForEnum: data)
    }

    func part1() async -> Any {
        await performTraversal(
            of: grid,
            startingPosition: .init(coordinates: .init(x: -1, y: 0), direction: .right)
        )
    }

    func part2() async -> Any {
        let grid = self.grid
        let lastXIndex = grid.values.keys.map(\.x).max()!
        let lastYIndex = grid.values.keys.map(\.y).max()!

        let bottomStartingPositions: [StartingPosition] = (0...lastXIndex).map {
            .init(coordinates: .init(x: $0, y: lastYIndex + 1), direction: .up)
        }

        let leftStartingPositions: [StartingPosition] = (0...lastYIndex).map {
            .init(coordinates: .init(x: -1, y: $0), direction: .right)
        }

        let rightStartingPositions: [StartingPosition] = (0...lastYIndex).map {
            .init(coordinates: .init(x: lastYIndex + 1, y: $0), direction: .left)
        }

        let topStartingPositions: [StartingPosition] = (0...lastXIndex).map {
            .init(coordinates: .init(x: $0, y: -1), direction: .down)
        }

        let startingPositions =
            bottomStartingPositions
            + leftStartingPositions
            + rightStartingPositions
            + topStartingPositions

        let results = await withTaskGroup(of: Int.self) { group in
            for startingPosition in startingPositions {
                group.addTask {
                    let result = await performTraversal(
                        of: grid,
                        startingPosition: startingPosition
                    )

                    return result
                }
            }

            var results: [Int] = []
            for await result in group {
                results.append(result)
                log("\(results.count) of \(startingPositions.count) finished")
            }

            return results
        }

        return results.max()!
    }

    private func performTraversal(of grid: DayGrid, startingPosition: StartingPosition) async -> Int {
        await grid.nextStep(
            from: startingPosition.coordinates,
            to: startingPosition.direction,
            currentlyEnergised: [:],
            cache: .init()
        ).keys.count
    }
}

private typealias EnergisedGrid = [DayGrid.Coordinates: Bool]

private enum Direction {
    case down
    case left
    case right
    case up
}

private extension Direction {
    var turnLeft: Direction {
        switch self {
        case .down:
            .right
        case .left:
            .down
        case .right:
            .up
        case .up:
            .left
        }
    }

    var turnRight: Direction {
        switch self {
        case .down:
            .left
        case .left:
            .up
        case .right:
            .down
        case .up:
            .right
        }
    }
}

private enum Value: Character, CustomStringConvertible, CaseIterable {
    case empty = "."
    case mirrorLeftUpRightDown = "/"
    case mirrorLeftDownRightUp = #"\"#
    case splitHorizontal = "-"
    case splitVertical = "|"

    var description: String {
        String(rawValue)
    }
}

private extension Value {
    func nextDirections(traveling direction: Direction) -> [Direction] {
        switch self {
        case .empty:
            [direction]
        case .mirrorLeftUpRightDown:
            [getMirrorLeftUpRightDown(traveling: direction)]
        case .mirrorLeftDownRightUp:
            [getMirrorLeftDownRightUp(traveling: direction)]
        case .splitHorizontal:
            getSplitHorizontal(traveling: direction)
        case .splitVertical:
            getSplitVertical(traveling: direction)
        }
    }

    private func getMirrorLeftUpRightDown(traveling direction: Direction) -> Direction {
        switch direction {
        case .down, .up:
            direction.turnRight
        case .left, .right:
            direction.turnLeft
        }
    }

    private func getMirrorLeftDownRightUp(traveling direction: Direction) -> Direction {
        switch direction {
        case .down, .up:
            direction.turnLeft
        case .left, .right:
            direction.turnRight
        }
    }

    private func getSplitHorizontal(traveling direction: Direction) -> [Direction] {
        switch direction {
        case .down, .up:
            [direction.turnLeft, direction.turnRight]
        case .left, .right:
            [direction]
        }
    }

    private func getSplitVertical(traveling direction: Direction) -> [Direction] {
        switch direction {
        case .down, .up:
            [direction]
        case .left, .right:
            [direction.turnLeft, direction.turnRight]
        }
    }
}

private typealias DayGrid = Grid<Value>
private extension DayGrid {

    subscript(key: Coordinates) -> Value? {
        get { values[key] }
    }

    func nextStep(
        from currentPosition: Coordinates,
        to direction: Direction,
        currentlyEnergised: EnergisedGrid,
        cache: Cache<History, Bool>
    ) async -> EnergisedGrid {
        let cacheKey = History(direction: direction, position: currentPosition)

        let cachedValue = await cache.object(for: cacheKey)
        guard cachedValue == nil else {
            log("breaking loop at \(currentPosition.x),\(currentPosition.y) towards \(direction)")
            return currentlyEnergised
        }

        await cache.set(true, for: cacheKey)

        log("nextStep from \(currentPosition.x),\(currentPosition.y) towards \(direction)")
        let nextCoordinates: Coordinates =
            switch direction {
            case .down:
                .init(x: currentPosition.x, y: currentPosition.y + 1)
            case .left:
                .init(x: currentPosition.x - 1, y: currentPosition.y)
            case .right:
                .init(x: currentPosition.x + 1, y: currentPosition.y)
            case .up:
                .init(x: currentPosition.x, y: currentPosition.y - 1)
            }

        guard let nextPosition = self[nextCoordinates] else {
            return currentlyEnergised
        }

        let nextDirections = nextPosition.nextDirections(traveling: direction)
        let updatedCurrentlyEnergised = {
            var grid = currentlyEnergised
            grid[nextCoordinates] = true
            return grid
        }()

        let energisedResult = await withTaskGroup(of: EnergisedGrid.self) { group in
            for nextDirection in nextDirections {
                group.addTask {
                    let results = await nextStep(
                        from: nextCoordinates,
                        to: nextDirection,
                        currentlyEnergised: updatedCurrentlyEnergised,
                        cache: cache
                    )

                    return results
                }
            }

            var results = updatedCurrentlyEnergised
            for await result in group {
                results.merge(result, uniquingKeysWith: { current, _ in current })
            }

            return results
        }

        return energisedResult
    }
}

private struct History: Hashable {
    let direction: Direction
    let position: DayGrid.Coordinates
}

private struct StartingPosition: Hashable {
    let coordinates: DayGrid.Coordinates
    let direction: Direction
}
