// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day14: AdventDay {
    var data: String

    func part1() async -> Any {
        let grid = DayGrid(data: data)
        let tiltedGrid = grid.tilting(direction: .north)
        return calculateLoad(on: tiltedGrid)
    }

    func part2() async -> Any {
        let grid = DayGrid(data: data)
        let tiltedGrid = await performAllCycles(grid: grid)
        return calculateLoad(on: tiltedGrid)
    }

    private func performAllCycles(grid: DayGrid) async -> DayGrid {
        await Task.detached {
            let cycles = 1_000_000_000
            var partialResults = [grid]
            var number = 0
            while number < cycles {
                let lastGrid = partialResults.last!
                guard let firstMatchIndex = partialResults.dropLast().firstIndex(of: lastGrid) else {
                    partialResults.append(performCycle(on: lastGrid))
                    number += 1
                    continue
                }

                let difference = partialResults.count - firstMatchIndex
                let numberOfResults = min(difference - 1, cycles - number)
                let droppedFirst = partialResults.dropFirst(firstMatchIndex + 1)
                let numberToDropFromEnd = droppedFirst.count - numberOfResults
                let newValues = droppedFirst.dropLast(max(numberToDropFromEnd, 0))
                partialResults.append(contentsOf: newValues)
                number += newValues.count
            }

            return partialResults.last!
        }.value
    }

    private let cache = Cache<DayGrid, DayGrid>()
    private func performCycle(on grid: DayGrid) -> DayGrid {
        if let cachedResult = cache[grid] {
            return cachedResult
        }

        let result = grid.tilting(direction: .north)
            .tilting(direction: .west)
            .tilting(direction: .south)
            .tilting(direction: .east)

        cache[grid] = result
        return result
    }

    private func calculateLoad(on tiltedGrid: DayGrid) -> Int {
        let roundedRocks = tiltedGrid.grid.values.filter {
            $0.value == .roundedRock
        }

        let numberOfRows = tiltedGrid.grid.values.map(\.key.y).max()! + 1
        return roundedRocks.map(\.key).reduce(into: 0) { partialResult, rock in
            partialResult += numberOfRows - rock.y
        }
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

    func tilting(direction: CompassDirection) -> DayGrid {
        var grid = self.grid
        let roundedRocks = grid.keysSortedClose(to: direction)
            .filter {
                grid[$0] == .roundedRock
            }

        for rock in roundedRocks {
            let newPosition = grid.moving(rock: rock, direction: direction)
            guard rock != newPosition else {
                continue
            }

            grid[newPosition] = .roundedRock
            grid[rock] = .empty
        }

        return .init(grid: grid)
    }
}

extension DayGrid: Equatable {
    static func == (lhs: DayGrid, rhs: DayGrid) -> Bool {
        lhs.grid == rhs.grid
    }
}

extension DayGrid: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(grid)
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

    func keysSortedClose(to direction: CompassDirection) -> [Key] {
        switch direction {
        case .east:
            keysSortedCloseToWest().reversed()
        case .north:
            keysSortedCloseToNorth()
        case .south:
            keysSortedCloseToNorth().reversed()
        case .west:
            keysSortedCloseToWest()
        }
    }

    private func keysSortedCloseToNorth() -> [Key] {
        values.keys
            .sorted {
                guard $0.y == $1.y else {
                    return $0.y < $1.y
                }

                return $0.x < $1.x
            }
    }

    private func keysSortedCloseToWest() -> [Key] {
        values.keys
            .sorted {
                guard $0.x == $1.x else {
                    return $0.x < $1.x
                }

                return $0.y < $1.y
            }
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

extension DayValue: Hashable {}
