// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation
import SwiftPriorityQueue

struct Day10: AdventDay {
    var data: String

    func part1() async -> Any {
        var queue = PriorityQueue<Input>()
        let lengthOfLoop = traverseGrid(maze: Maze(data: data), queue: &queue)
        return lengthOfLoop / 2
    }

    func part2() async -> Any {
        "Not implemented"
    }

    private func traverseGrid(
        maze: Maze,
        queue: inout PriorityQueue<Input>
    ) -> Int {
        for direction in CompassDirection.allCases {
            queue.push(
                .init(
                    from: maze.startingPoint,
                    direction: direction,
                    history: .init()
                )
            )
        }

        var result: History?

        while result == nil {
            guard let input = queue.pop() else {
                log("Skipping")
                continue
            }

            guard let historyOfLoop = performStep(maze: maze, queue: &queue, input: input) else {
                continue
            }

            result = historyOfLoop
        }

        return result!.values.count
    }

    private func performStep(
        maze: Maze,
        queue: inout PriorityQueue<Input>,
        input: Input
    ) -> History? {
        log("\(input.description): Processing")

        guard
            let position = maze.grid.getCoordinates(from: input.from, direction: input.direction),
            let value = maze.grid[position],
            value.entryPoints.contains(input.direction)
        else {
            log("\(input.description): Invalid")
            return nil
        }

        guard !input.history.values.contains(position) else {
            log("\(input.description): Looped back on self")
            return nil
        }

        guard value != .startingPosition else {
            log("\(input.description): Found starting position")
            return input.history.new(position)
        }

        for direction in value.directions {
            queue.push(
                input.next(from: position, direction: direction)
            )
        }

        return nil
    }
}

// MARK: - History

private final class History {
    let values: [Coordinates]

    init(values: [Coordinates] = []) {
        self.values = values
    }

    func new(_ input: Coordinates) -> History {
        .init(values: values + [input])
    }
}

extension History: Equatable {
    static func == (lhs: History, rhs: History) -> Bool {
        lhs.values == rhs.values
    }
}

// MARK: - Input

private final class Input {
    let from: Coordinates
    let direction: CompassDirection
    let history: History

    init(from: Coordinates, direction: CompassDirection, history: History) {
        self.from = from
        self.direction = direction
        self.history = history
    }

    func next(from: Coordinates, direction: CompassDirection) -> Input {
        .init(
            from: from,
            direction: direction,
            history: self.history.new(from)
        )
    }
}

extension Input: Comparable {
    static func < (lhs: Input, rhs: Input) -> Bool {
        guard lhs.history.values.count == rhs.history.values.count else {
            return lhs.history.values.count < rhs.history.values.count
        }

        return lhs.from < rhs.from
    }
}

extension Input: CustomStringConvertible {
    var description: String {
        "\(from.description) -> \(direction)"
    }
}

extension Input: Equatable {
    static func == (lhs: Input, rhs: Input) -> Bool {
        lhs.from == rhs.from && lhs.direction == rhs.direction && lhs.history == rhs.history
    }
}

// MARK: - DayGrid

private final class Maze {
    let grid: Grid<Coordinates, Value>
    let startingPoint: Coordinates

    init(data: String) {
        self.grid = Grid(data: data).removing(value: .ground)
        self.startingPoint = grid.values.first(where: { $0.value == .startingPosition })!.key
    }
}

// MARK: - Value

private enum Value: String, CaseIterable {
    case bendNorthEast = "L"
    case bendNorthWest = "J"
    case bendSouthEast = "F"
    case bendSouthWest = "7"
    case ground = "."
    case pipeHorizontal = "-"
    case pipeVertical = "|"
    case startingPosition = "S"

    var entryPoints: [CompassDirection] {
        directions.map(\.opposite)
    }

    var directions: [CompassDirection] {
        switch self {
        case .bendNorthEast:
            [.north, .east]
        case .bendNorthWest:
            [.north, .west]
        case .bendSouthEast:
            [.south, .east]
        case .bendSouthWest:
            [.south, .west]
        case .ground:
            []
        case .pipeHorizontal:
            [.east, .west]
        case .pipeVertical:
            [.north, .south]
        case .startingPosition:
            CompassDirection.allCases
        }
    }
}

extension Value: CustomStringConvertible {
    var description: String {
        rawValue
    }
}
