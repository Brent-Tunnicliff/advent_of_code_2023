// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

protocol CoordinatesType: Hashable {
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
    static func < (lhs: Coordinates, rhs: Coordinates) -> Bool {
        guard lhs.x != rhs.x else {
            return lhs.y < rhs.y
        }

        return lhs.x < rhs.x
    }
}

extension Coordinates: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(x),\(y)"
    }
}

// MARK: - 3D

struct ThreeDimensionalCoordinates: CoordinatesType {
    let x: Int
    let y: Int
    let z: Int
}

extension ThreeDimensionalCoordinates: Comparable {
    static func < (lhs: ThreeDimensionalCoordinates, rhs: ThreeDimensionalCoordinates) -> Bool {
        if lhs.z != rhs.z {
            return lhs.z < rhs.z
        }

        if lhs.x != rhs.x {
            return lhs.x < rhs.x
        }

        return lhs.y < rhs.y
    }
}

extension ThreeDimensionalCoordinates: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(x),\(y),\(z)"
    }
}
