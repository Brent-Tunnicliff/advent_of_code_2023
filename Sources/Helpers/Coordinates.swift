// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Coordinates: Hashable {
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
