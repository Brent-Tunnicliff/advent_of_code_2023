// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

// MARK: - Grid

struct Grid<Value: CustomStringConvertible> {
    private(set) var values: [Coordinates: Value]

    subscript(key: Coordinates) -> Value? {
        get { values[key] }
        set { values[key] = newValue }
    }

    init() {
        self.values = [:]
    }

    init(values: [Coordinates: Value]) {
        self.values = values
    }

    init(data: String, valueMapper: (String) -> Value) {
        let values = data.split(separator: "\n")
            .enumerated()
            .reduce(into: [Coordinates: Value]()) { partialResult, item in
                let (y, line) = item
                for (x, value) in line.enumerated() {
                    partialResult[.init(x: x, y: y)] = valueMapper(String(value))
                }
            }

        self.init(values: values)
    }
}

// MARK: CustomStringConvertible

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

// MARK: Positions

extension Grid {
    var bottomLeft: Coordinates {
        .init(x: minX, y: maxY)
    }

    var bottomRight: Coordinates {
        .init(x: maxX, y: maxY)
    }

    var topLeft: Coordinates {
        .init(x: minX, y: minY)
    }

    var topRight: Coordinates {
        .init(x: maxX, y: minY)
    }

    private var minX: Int {
        self.values.keys.map(\.x).min()!
    }

    private var minY: Int {
        self.values.keys.map(\.y).min()!
    }

    private var maxX: Int {
        self.values.keys.map(\.x).max()!
    }

    private var maxY: Int {
        self.values.keys.map(\.y).max()!
    }
}

// MARK: Traversal

extension Grid {
    func getCoordinates(from: Coordinates, direction: CompassDirection) -> Coordinates? {
        let coordinates: Coordinates =
            switch direction {
            case .east: .init(x: from.x + 1, y: from.y)
            case .north: .init(x: from.x, y: from.y - 1)
            case .south: .init(x: from.x, y: from.y + 1)
            case .west: .init(x: from.x - 1, y: from.y)
            }
        return values.keys.contains(coordinates) ? coordinates : nil
    }
}

// MARK: Value is CaseIterable

extension Grid where Value: CaseIterable {
    init(data: String) {
        self.init(data: data) { value in
            Value.allCases.first(where: { $0.description == String(value) })!
        }
    }
}

// MARK: Value is Int

extension Grid where Value == Int {
    init(data: String) {
        self.init(data: data) { Int($0)! }
    }
}

// MARK: Value is String

extension Grid where Value == String {
    init(data: String) {
        self.init(data: data) { $0 }
    }
}

// MARK: - Coordinates

struct Coordinates: Hashable {
    let x: Int
    let y: Int
}

extension Coordinates: Comparable {
    static func < (lhs: Coordinates, rhs: Coordinates) -> Bool {
        guard lhs.x != rhs.x else {
            return lhs.y < rhs.y
        }

        return lhs.x < rhs.x
    }
}
