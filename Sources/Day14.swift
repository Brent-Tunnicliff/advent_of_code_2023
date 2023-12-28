// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day14: AdventDay {
    var data: String

    func part1() async -> Any {
        let grid = DayGrid(data: data)
        let tiltedGrid = grid.tiltingNorth()

        let roundedRocks = tiltedGrid.grid.values.filter {
            $0.value == .roundedRock
        }

        let numberOfRows = tiltedGrid.grid.values.map(\.key.y).max()! + 1
        return roundedRocks.map(\.key).reduce(into: 0) { partialResult, rock in
            partialResult += numberOfRows - rock.y
        }
    }

    func part2() async -> Any {
        "Not implemented"
    }
}

private class DayGrid {
    let grid: Grid<Coordinates, DayValue>

    init(data: String) {
        self.grid = Grid(data: data)
    }

    private init(grid: Grid<Coordinates, DayValue>) {
        self.grid = grid
    }

    func tiltingNorth() -> DayGrid {
        var grid = self.grid
        let roundedRocks = grid.values
            .filter {
                $0.value == .roundedRock
            }
            .keys
            .sorted {
                guard $0.y == $1.y else {
                    return $0.y < $1.y
                }

                return $0.x < $1.x
            }

        for rock in roundedRocks {
            let newPosition = grid.moving(rock: rock, direction: .north)
            guard rock != newPosition else {
                continue
            }

            grid[newPosition] = .roundedRock
            grid[rock] = .empty
        }

        return .init(grid: grid)
    }
}

private extension Grid where Key == Coordinates, Value == DayValue {
    func moving(rock: Coordinates, direction: CompassDirection) -> Coordinates {
        let nextPosition = rock.next(in: direction)
        guard self[nextPosition] == .empty else {
            return rock
        }

        return moving(rock: nextPosition, direction: direction)
    }
}

private enum DayValue: String, CaseIterable {
    case cubeRock = "#"
    case empty = "."
    case roundedRock = "O"
}

extension DayValue: CustomStringConvertible {
    var description: String {
        rawValue
    }
}
