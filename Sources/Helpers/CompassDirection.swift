// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

enum CompassDirection: CaseIterable {
    case east
    case north
    case south
    case west
}

extension CompassDirection {
    var opposite: CompassDirection {
        switch self {
        case .east:
            .west
        case .north:
            .south
        case .south:
            .north
        case .west:
            .east
        }
    }

    var turnLeft: CompassDirection {
        switch self {
        case .east:
            .north
        case .north:
            .west
        case .south:
            .east
        case .west:
            .south
        }
    }

    var turnRight: CompassDirection {
        switch self {
        case .east:
            .south
        case .north:
            .east
        case .south:
            .west
        case .west:
            .north
        }
    }
}
