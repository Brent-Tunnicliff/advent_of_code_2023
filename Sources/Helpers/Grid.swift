// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

// MARK: - Grid

struct Grid<Key: CoordinatesType, Value: CustomStringConvertible> {
    private(set) var values: [Key: Value]

    subscript(key: Key) -> Value? {
        get { values[key] }
        set { values[key] = newValue }
    }

    init() {
        self.values = [:]
    }

    init(values: [Key: Value]) {
        self.values = values
    }
}

extension Grid where Key == Coordinates {
    init(data: String, valueMapper: (String) -> Value) {
        let values = data.split(separator: "\n")
            .enumerated()
            .reduce(into: [Key: Value]()) { partialResult, item in
                let (y, line) = item
                for (x, value) in line.enumerated() {
                    partialResult[.init(x: x, y: y)] = valueMapper(String(value))
                }
            }

        self.init(values: values)
    }
}

extension Grid where Value: Equatable {
    func removing(value: Value) -> Grid {
        .init(values: values.filter { $0.value != value })
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

extension Grid where Key == Coordinates {
    func getCoordinates(from: Key, direction: CompassDirection) -> Key? {
        let coordinates = from.next(in: direction)
        return values.keys.contains(coordinates) ? coordinates : nil
    }
}

// MARK: Value is CaseIterable

extension Grid where Key == Coordinates, Value: CaseIterable {
    init(data: String) {
        self.init(data: data) { value in
            Value.allCases.first(where: { $0.description == value })!
        }
    }
}

// MARK: Value is Int

extension Grid where Key == Coordinates, Value == Int {
    init(data: String) {
        self.init(data: data) { Int($0)! }
    }
}

// MARK: Value is String

extension Grid where Key == Coordinates, Value == String {
    init(data: String) {
        self.init(data: data) { $0 }
    }
}
