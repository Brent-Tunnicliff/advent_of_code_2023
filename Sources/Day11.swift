// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day11: AdventDay {
    var data: String

    func part1() async -> Any {
        let grid = getGrid()
        precondition(grid.description.trimmingCharacters(in: .newlines) == data.trimmingCharacters(in: .newlines))

        grid.expanded()

        let galaxies = grid.values
            .filter { $0.value == .galaxy }
            .sorted(by: { $0.key < $1.key })

        return galaxies.reduce(into: 0) { partialResult, position in
            let filteredGalaxies = galaxies.filter {
                $0.key > position.key
            }

            for galaxy in filteredGalaxies {
                partialResult += getDistance(between: galaxy.key, and: position.key)
            }
        }
    }

    func part2() async -> Any {
        "Not implemented"
    }

    func getGrid() -> Grid {
        data.split(separator: "\n").enumerated().reduce(into: Grid()) { partialResult, item in
            let (y, line) = item
            for (x, value) in line.enumerated() {
                partialResult[.init(x: x, y: y)] = value == "#" ? .galaxy : .empty
            }
        }
    }

    private func getDistance(between origin: Grid.Coordinates, and destination: Grid.Coordinates) -> Int {
        let xDifference = max(origin.x, destination.x) - min(origin.x, destination.x)
        let yDifference = max(origin.y, destination.y) - min(origin.y, destination.y)
        return xDifference + yDifference
    }
}

extension Day11 {
    class Grid: CustomStringConvertible {
        struct Coordinates: Hashable, Comparable {
            let x: Int
            let y: Int

            static func < (lhs: Grid.Coordinates, rhs: Grid.Coordinates) -> Bool {
                guard lhs.x != rhs.x else {
                    return lhs.y < rhs.y
                }

                return lhs.x < rhs.x
            }
        }

        enum Value: String {
            case empty = "."
            case galaxy = "#"
        }

        var description: String {
            String(
                values.keys.reduce(into: [Int: [Int: String]]()) { partialResult, coordinates in
                    if partialResult[coordinates.y] == nil {
                        partialResult[coordinates.y] = [:]
                    }

                    partialResult[coordinates.y]![coordinates.x] = values[coordinates]!.rawValue
                }
                .map { $0 }
                .sorted(by: { $0.key < $1.key })
                .reduce(into: "") { partialResult, item in
                    for character in item.value.sorted(by: { $0.key < $1.key }) {
                        partialResult += character.value
                    }

                    partialResult += "\n"
                }
                .dropLast()
            )
        }

        private(set) var values: [Coordinates: Value] = [:]
        private var xLength: Int {
            values.filter { $0.key.y == 0 }.count
        }

        private var yLength: Int {
            values.filter { $0.key.x == 0 }.count
        }

        subscript(key: Coordinates) -> Value {
            get { values[key]! }
            set { values[key] = newValue }
        }

        func expanded() {
            let whereToExpand = getWhereToExpand()
            let modifiedCoordinates = getModifiedCoordinates(whereToExpand)
            insertExpandedValues(at: whereToExpand)

            for coordinates in modifiedCoordinates {
                values[coordinates.key] = coordinates.value
            }
        }

        private func getWhereToExpand() -> (x: [Int], y: [Int]) {
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

        private func getModifiedCoordinates(_ expanding: (x: [Int], y: [Int])) -> [Coordinates: Value] {
            values.reduce(into: [Coordinates: Value]()) { partialResult, coordinates in
                let newX = coordinates.key.x + expanding.x.filter { $0 <= coordinates.key.x }.count
                let newY = coordinates.key.y + expanding.y.filter { $0 <= coordinates.key.y }.count
                partialResult[.init(x: newX, y: newY)] = coordinates.value
            }
        }

        private func insertExpandedValues(at expanding: (x: [Int], y: [Int])) {
            let yLength = self.yLength + expanding.y.count
            let xLength = self.xLength + expanding.x.count

            for (index, x) in expanding.x.enumerated() {
                for y in (0..<yLength) {
                    values[.init(x: x + index, y: y)] = .empty
                }
            }

            for (index, y) in expanding.y.enumerated() {
                for x in (0..<xLength) {
                    values[.init(x: x, y: y + index)] = .empty
                }
            }
        }
    }
}
