// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation
import SwiftPriorityQueue

// MARK: - Day 17

struct Day17: AdventDay {
    var data: String

    private var grid: DayGrid {
        DayGrid(data: data)
    }

    func part1() async -> Any {
        let grid = self.grid
        let result = await performTraversal(
            of: grid,
            startingLocation: grid.topLeft,
            destination: grid.bottomRight
        )

        if !testsAreRunning {
            assert(result < 1142, "\(result) is too high")
        }

        return result
    }

    func part2() async -> Any {
        "Not implemented"
    }

    private func performTraversal(
        of grid: DayGrid,
        startingLocation: Coordinates,
        destination: Coordinates
    ) async -> HeatLoss {
        var results: [HeatLoss?] = []
        let directions: [CompassDirection] = [.south, .east]
        for direction in directions {
            results.append(
                await grid.getLowestHeatLoss(
                    .init(
                        destination: destination,
                        from: startingLocation,
                        direction: direction,
                        heatLoss: 0,
                        history: .init()
                    )
                )
            )
        }

        return results.compacted().min()!
    }
}

// MARK: - Cache

private struct HeatLossCacheKey: Hashable {
    let position: Coordinates
    let direction: CompassDirection
    let atMaxDirection: Bool
}

// MARK: - DayGrid

private class DayGrid {
    var bottomRight: Coordinates {
        grid.bottomRight
    }

    var topLeft: Coordinates {
        grid.topLeft
    }

    private let grid: Grid<Int>

    // New learning, priority queue is what make this possible.
    // We are always pulling the value that is closest to the destination, while also the lowest heat loss.
    private var priorityQueue = PriorityQueue<NextStepInput>()
    private var lowestValueCache: [Int] = []

    private var heatLossCache: [HeatLossCacheKey: HeatLoss] = [:]

    init(data: String) {
        self.grid = Grid<Int>(data: data)
    }

    func getLowestHeatLoss(_ input: NextStepInput) async -> HeatLoss? {
        await processNextStep(input)
        while !priorityQueue.isEmpty {
            await processNextStep(priorityQueue.pop()!)
        }

        return lowestValueCache.min()
    }

    func processNextStep(_ input: NextStepInput) async {
        // If the current path is longer than the known fastest path, then kill it.
        let lowestValue = lowestValueCache.min() ?? .max
        guard input.heatLoss < lowestValue else {
            return
        }

        guard let position = grid.getCoordinates(from: input.from, direction: input.direction) else {
            return
        }

        let cacheKey = input.heatLossCacheKey
        guard input.heatLoss < (heatLossCache[cacheKey] ?? .max) else {
            return
        }

        heatLossCache[cacheKey] = input.heatLoss

        guard position != input.destination else {
            let totalHeatLoss = input.heatLoss + grid[position]!
            log("Found path with heat loss of \(totalHeatLoss)")
            lowestValueCache.append(totalHeatLoss)
            return
        }

        log("Moving from \(input.from) \(input.direction) to location \(position), heat loss \(input.heatLoss)")

        let expectedHistoryCount = 2
        let history = input.history.getLast(expectedHistoryCount)
        let hasExpectedHistoryCount = history.count >= expectedHistoryCount
        let previousHistoryIsStraightLine = history.filter {
            $0.direction == input.direction
        }.count == expectedHistoryCount
        let hasHitStraightLimit = hasExpectedHistoryCount && previousHistoryIsStraightLine

        let nextDirections: [CompassDirection] = [
            input.direction.turnLeft,
            input.direction.turnRight,
            hasHitStraightLimit ? nil : input.direction,
        ].compactMap { $0 }

        // Insert the next steps into the priorityQueue.
        for direction in nextDirections {
            priorityQueue.push(
                input.next(
                    from: position,
                    direction: direction,
                    newHeatLossValue: grid[position]!
                )
            )
        }
    }
}

// MARK: - HeatLoss

private typealias HeatLoss = Int

// MARK: - NextStepInput

private struct NextStepInput: Comparable {
    let destination: Coordinates
    let from: Coordinates
    let direction: CompassDirection
    let heatLoss: HeatLoss
    let history: History

    var heatLossCacheKey: HeatLossCacheKey {
        .init(
            position: from,
            direction: direction,
            atMaxDirection: history.getLast(2).filter { $0.direction == direction }.count == 2
        )
    }

    private var distanceFromDestination: Int {
        (destination.x - from.x) + (destination.y - from.y)
    }

    static func < (lhs: NextStepInput, rhs: NextStepInput) -> Bool {
        guard lhs.distanceFromDestination != rhs.distanceFromDestination else {
            return lhs.heatLoss > rhs.heatLoss
        }

        return lhs.distanceFromDestination < rhs.distanceFromDestination
    }
}

private extension NextStepInput {
    func next(from: Coordinates, direction: CompassDirection, newHeatLossValue: HeatLoss) -> NextStepInput {
        let heatLoss = self.heatLoss + newHeatLossValue
        return .init(
            destination: self.destination,
            from: from,
            direction: direction,
            heatLoss: heatLoss,
            history: history.adding(self)
        )
    }
}

// MARK: - History

private struct History: Equatable {
    var count: Int {
        values.count
    }

    private let values: [NextStepInput]

    init(values: [NextStepInput] = []) {
        self.values = values
    }

    func adding(_ newValue: NextStepInput) -> History {
        .init(values: self.values + [newValue])
    }

    func getLast(_ number: Int) -> [NextStepInput] {
        guard values.count > number else {
            return values
        }

        return Array(values.dropFirst(values.count - number))
    }
}
