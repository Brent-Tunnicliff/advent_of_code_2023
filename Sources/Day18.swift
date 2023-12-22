// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day18: AdventDay {
    var data: String

    private var instructions: [Instruction] {
        data.split(separator: "\n").map {
            let sections = $0.split(separator: " ").map { String($0) }

            let direction = CompassDirection(value: sections[0])
            let distance = Int(sections[1])!
            let colour = sections[2].trimmingCharacters(in: ["(", ")"])

            return Instruction(colour: colour, direction: direction, distance: distance)
        }
    }

    private var grid: DayGrid {
        DayGrid(instructions: instructions)
    }

    func part1() async -> Any {
        let grid = self.grid
        let filled = grid.filled()
        return filled.values.count
    }

    func part2() async -> Any {
        "Not implemented"
    }
}

private typealias DayGrid = Grid<String>

private struct Instruction {
    let colour: String
    let direction: CompassDirection
    let distance: Int
}

private extension CompassDirection {
    init(value: String) {
        self =
            switch value.uppercased() {
            case "D": .south
            case "L": .west
            case "R": .east
            case "U": .north
            default: preconditionFailure("Unexpected value \(value)")
            }
    }
}

private extension DayGrid {
    init(instructions: [Instruction]) {
        var lastCoordinates = Coordinates(x: 0, y: 0)
        let results = instructions.reduce(into: [Coordinates: String]()) { partialResult, instruction in
            for _ in (0..<instruction.distance) {
                let newCoordinates = lastCoordinates.next(in: instruction.direction)
                partialResult[newCoordinates] = instruction.colour
                lastCoordinates = newCoordinates
            }
        }

        self.init(values: results)
    }

    func filled() -> DayGrid {
        let filledValue = "filled"
        var newGrid = DayGrid(values: values)
        let firstCoordinates = newGrid.values.keys.min().map {
            Coordinates(x: $0.x + 1, y: $0.y + 1)
        }!

        var coordinatesToFill = Set([firstCoordinates])

        while !coordinatesToFill.isEmpty {
            let current = coordinatesToFill.popFirst()!
            newGrid[current] = filledValue

            for next in newGrid.fillSurrounding(current) {
                coordinatesToFill.insert(next)
            }
        }

        return newGrid
    }

    private func fillSurrounding(_ coordinates: Coordinates) -> [Coordinates] {
        CompassDirection.allCases.compactMap {
            let newCoordinates = coordinates.next(in: $0)
            return self[newCoordinates] == nil ? newCoordinates : nil
        }
    }
}
