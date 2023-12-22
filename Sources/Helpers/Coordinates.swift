// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Coordinates: Hashable {
    let x: Int
    let y: Int
}

extension Coordinates {
    func next(in direction: CompassDirection) -> Coordinates {
        switch direction {
        case .east: .init(x: x + 1, y: y)
        case .north: .init(x: x, y: y - 1)
        case .south: .init(x: x, y: y + 1)
        case .west: .init(x: x - 1, y: y)
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
