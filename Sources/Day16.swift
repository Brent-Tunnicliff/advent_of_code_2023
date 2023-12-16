// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day16: AdventDay {
    var data: String

    private var grid: DayGrid {
        DayGrid(data: data)
    }

    func part1() async -> Any {
        grid.nextStep(
            from: .init(x: -1, y: 0),
            to: .right,
            currentlyEnergised: [:]
        ).keys.count
    }

    func part2() async -> Any {
        "Not implemented"
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
    private static var cache: [History] = []

    func nextStep(
        from currentPosition: Coordinates,
        to direction: Direction,
        currentlyEnergised: EnergisedGrid
    ) -> EnergisedGrid {
        let pathRanPreviously = Self.cache.contains(
            where: { $0.direction == direction && $0.position == currentPosition }
        )
        guard !pathRanPreviously else {
            log("breaking loop at \(currentPosition.x),\(currentPosition.y) towards \(direction)")
            return currentlyEnergised
        }

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

        Self.cache.append(.init(direction: direction, position: currentPosition))
        let nextDirections = nextPosition.nextDirections(traveling: direction)

        var updatedCurrentlyEnergised = currentlyEnergised
        updatedCurrentlyEnergised[nextCoordinates] = true

        for nextDirection in nextDirections {
            updatedCurrentlyEnergised.merge(
                nextStep(from: nextCoordinates, to: nextDirection, currentlyEnergised: updatedCurrentlyEnergised),
                uniquingKeysWith: { current, _ in current }
            )
        }

        return updatedCurrentlyEnergised
    }
}

private struct History {
    let direction: Direction
    let position: DayGrid.Coordinates
}
