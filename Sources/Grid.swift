// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

// MARK: - Grid

struct Grid<Value: CustomStringConvertible> {
    private(set) var values: [Coordinates: Value] = [:]

    subscript(key: Coordinates) -> Value {
        get { values[key]! }
        set { values[key] = newValue }
    }
}

extension Grid: CustomStringConvertible {
    var description: String {
        String(
            values.keys.reduce(into: [Int: [Int: String]]()) { partialResult, coordinates in
                if partialResult[coordinates.y] == nil {
                    partialResult[coordinates.y] = [:]
                }

                partialResult[coordinates.y]![coordinates.x] = values[coordinates]!.description
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
}

// MARK: - Coordinates

extension Grid {
    struct Coordinates: Hashable {
        let x: Int
        let y: Int
    }
}

extension Grid.Coordinates: Comparable {
    static func < (lhs: Grid.Coordinates, rhs: Grid.Coordinates) -> Bool {
        guard lhs.x != rhs.x else {
            return lhs.y < rhs.y
        }

        return lhs.x < rhs.x
    }
}
