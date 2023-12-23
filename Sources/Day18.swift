// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day18: AdventDay {
    var data: String

    private var partOneInstructions: [Instruction] {
        data.split(separator: "\n").map {
            let sections = $0.split(separator: " ").map { String($0) }

            let direction = CompassDirection(value: sections[0])
            let distance = Int(sections[1])!
            let colour = sections[2].trimmingCharacters(in: ["(", ")"])

            return Instruction(colour: colour, direction: direction, distance: distance)
        }
    }

    private var partTwoInstructions: [Instruction] {
        data.split(separator: "\n").map {
            let sections = $0.split(separator: " ").map { String($0) }

            let hex = sections[2].trimmingCharacters(in: ["(", ")"])
            let distance = UInt64(hex.dropLast().trimmingPrefix("#"), radix: 16)!
            let direction = CompassDirection(value: String(hex.last!))

            return Instruction(colour: "\(sections[0]) \(sections[1])", direction: direction, distance: Int(distance))
        }
    }

    func part1() async -> Any {
        let instructions = partOneInstructions
        let points = map(instructions: instructions)
        return calculateArea(points, instructions)
    }

    func part2() async -> Any {
        let instructions = partTwoInstructions
        let points = map(instructions: instructions)
        return calculateArea(points, instructions)
    }

    private func map(instructions: [Instruction]) -> [Coordinates] {
        instructions.reduce(into: [Coordinates]([.init(x: 0, y: 0)])) { partialResult, instruction in
            let lastPoint = partialResult.last!
            partialResult.append(lastPoint.next(in: instruction.direction, distance: instruction.distance))
        }
    }

    private func calculateArea(_ points: [Coordinates], _ instructions: [Instruction]) -> Int {
        let polygonArea = calculatePolygonArea(points)
        let perimeterLength = calculatePerimeterLength(instructions)
        let interiorArea = calculateInteriorArea(area: polygonArea, perimeter: perimeterLength)
        return interiorArea + perimeterLength
    }

    private func calculatePolygonArea(_ points: [Coordinates]) -> Int {
        let count = points.count

        var result = 0
        for (index, point) in points.enumerated() {
            let other = index < count - 1 ? points[index + 1] : points[0]
            result += point.x * other.y - point.y * other.x
        }

        return result / 2
    }

    private func calculatePerimeterLength(_ instructions: [Instruction]) -> Int {
        var result = 0
        for instruction in instructions {
            result += instruction.distance
        }

        return result
    }

    private func calculateInteriorArea(area: Int, perimeter: Int) -> Int {
        area - (perimeter / 2) + 1
    }
}

private typealias DayGrid = Grid<Coordinates, String>

private struct Instruction {
    let colour: String
    let direction: CompassDirection
    let distance: Int
}

private extension CompassDirection {
    init(value: String) {
        self =
            switch value.uppercased() {
            case "D", "1": .south
            case "L", "2": .west
            case "R", "0": .east
            case "U", "3": .north
            default: preconditionFailure("Unexpected value \(value)")
            }
    }
}
