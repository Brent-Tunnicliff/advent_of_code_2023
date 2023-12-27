// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation
import simd

protocol CoordinatesType: Hashable, Comparable, CustomStringConvertible {
    var x: Int { get }
    var y: Int { get }
}

// MARK: - 2D

struct Coordinates: CoordinatesType {
    let x: Int
    let y: Int
}

extension Coordinates {
    func next(in direction: CompassDirection, distance: Int = 1) -> Coordinates {
        switch direction {
        case .east: .init(x: x + distance, y: y)
        case .north: .init(x: x, y: y - distance)
        case .south: .init(x: x, y: y + distance)
        case .west: .init(x: x - distance, y: y)
        }
    }
}

extension Coordinates: Comparable {
    private var comparableValue: Int {
        x + y
    }

    static func < (lhs: Coordinates, rhs: Coordinates) -> Bool {
        guard lhs.comparableValue == rhs.comparableValue else {
            return lhs.comparableValue < rhs.comparableValue
        }

        guard lhs.x == rhs.x else {
            return lhs.x < rhs.x
        }

        return lhs.y < rhs.y
    }
}

extension Coordinates: CustomStringConvertible {
    var description: String {
        "\(x),\(y)"
    }
}

extension Coordinates: CustomDebugStringConvertible {
    var debugDescription: String {
        description
    }
}

// MARK: - 3D

struct ThreeDimensionalCoordinates: CoordinatesType {
    let x: Int
    let y: Int
    let z: Int

    var twoDimensional: Coordinates {
        .init(x: x, y: y)
    }
}

extension ThreeDimensionalCoordinates: Comparable {
    private var comparableValue: Int {
        x + y + z
    }

    static func < (lhs: ThreeDimensionalCoordinates, rhs: ThreeDimensionalCoordinates) -> Bool {
        guard lhs.comparableValue == rhs.comparableValue else {
            return lhs.comparableValue < rhs.comparableValue
        }

        guard lhs.z == rhs.z else {
            return lhs.z < rhs.z
        }

        guard lhs.x == rhs.x else {
            return lhs.x < rhs.x
        }

        return lhs.y < rhs.y
    }
}

extension ThreeDimensionalCoordinates: CustomStringConvertible {
    var description: String {
        "\(x),\(y),\(z)"
    }
}

extension ThreeDimensionalCoordinates: CustomDebugStringConvertible {
    var debugDescription: String {
        description
    }
}

// MARK: - Line

struct Line<Value: CoordinatesType> {
    let from: Value
    let to: Value
}

extension Line: CustomStringConvertible {
    var description: String {
        "\(from.description)-\(to.description)"
    }
}

extension Line: Hashable {}

extension Line where Value == Coordinates {
    // Since this is using Int instead of Double the accuracy isn't great, but should be good enough.
    func extending(within box: Box<Value>) -> Line {
        let boxX = box.corners.map(\.x)
        let boxY = box.corners.map(\.y)

        let boxWidth = boxX.max()! - boxX.min()!
        let boxHeight = boxY.max()! - boxY.min()!
        let length = (boxWidth + boxHeight) * 2

        let lengthOfLine = Int(sqrt(pow(Double(to.x - from.x), 2.0) + pow(Double(to.y - from.y), 2.0)))

        // Found solution here https://stackoverflow.com/a/17761763.
        // Xc = Xa + (AC * (Xb - Xa) / AB)
        let newToX = from.x + (length * (to.x - from.x)) / lengthOfLine
        // Yc = Ya + (AC * (Yb - Ya) / AB)
        let newToY = from.y + (length * (to.y - from.y)) / lengthOfLine

        return Line(
            from: from,
            to: Coordinates(x: Int(newToX), y: Int(newToY))
        )
    }

    // Solution found here https://stackoverflow.com/a/45931831.
    func overlaps(_ other: Line) -> Value? {
        let p1 = from.simdValue
        let p2 = to.simdValue
        let p3 = other.from.simdValue
        let p4 = other.to.simdValue

        let matrix = simd_double2x2(p4 - p3, p1 - p2)
        guard matrix.determinant != 0 else {
            // Determinent == 0 => parallel lines
            return nil
        }

        let multipliers = matrix.inverse * (p1 - p3)

        // If either of the multipliers is outside the range 0 ... 1, then the
        // intersection would be off the end of one of the line segments.
        guard
            (0.0...1.0).contains(multipliers.x),
            (0.0...1.0).contains(multipliers.y)
        else {
            return nil
        }

        let result = p1 + multipliers.y * (p2 - p1)

        // Will converting double back to int cause issues?
        return .init(
            x: Int(result.x),
            y: Int(result.y)
        )
    }
}

extension Line where Value == ThreeDimensionalCoordinates {
    var twoDimensionalLine: Line<Coordinates> {
        .init(from: from.twoDimensional, to: to.twoDimensional)
    }
}

private extension Coordinates {
    var simdValue: simd_double2 {
        .init(x: Double(x), y: Double(y))
    }
}

// MARK: - Box

struct Box<Value: CoordinatesType> {
    let corners: [Value]
    let lines: [Line<Value>]

    private init(_ corners: [Value], _ lines: [Line<Value>]) {
        self.corners = corners
        self.lines = lines
    }
}

extension Box: CustomStringConvertible {
    var description: String {
        corners.description
    }
}

extension Box where Value == Coordinates {
    init(bottomLeft: Value, bottomRight: Value, topLeft: Value, topRight: Value) {
        let lines: [Line<Value>] = [
            .init(from: bottomLeft, to: bottomRight),
            .init(from: bottomLeft, to: topLeft),
            .init(from: bottomRight, to: topRight),
            .init(from: topLeft, to: topRight),
        ]

        self.init([bottomLeft, bottomRight, topLeft, topRight], lines)
    }

    func contains(_ coordinates: Value) -> Bool {
        let boxXValues = corners.map(\.x)
        let boxYValues = corners.map(\.y)

        let isWithX = (boxXValues.min()!...boxXValues.max()!).contains(coordinates.x)
        let isWithY = (boxYValues.min()!...boxYValues.max()!).contains(coordinates.y)

        return isWithX && isWithY
    }
}
