// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day23: AdventDay {
    var data: String

    func part1() async -> Any {
        await getPathLengths(isSlippery: true).max()!
    }

    func part2() async -> Any {
        let result = await getPathLengths(isSlippery: false).max()!

        if testsAreNotRunning {
            precondition(result > 2190, "2190 is too low")
        }

        return result
    }

    func getPathLengths(isSlippery: Bool) async -> [Int] {
        let grid = DayGrid(data: data)
        let priorityQueue = PriorityQueue<Input>()
        let results = ResultsCache()

        await nextStep(
            destination: grid.endPosition,
            grid: grid,
            isSlippery: isSlippery,
            priorityQueue: priorityQueue,
            results: results,
            input: Input(coordinates: grid.startingPosition, direction: .south, history: .init())
        )

        let runningJobs = RunningJobs()
        await withTaskGroup(of: Void.self) { group in
            while await shouldKeepLooping(priorityQueue: priorityQueue, runningJobs: runningJobs) {
                guard let input = await priorityQueue.pop() else {
                    continue
                }

                let jobID = UUID()
                await runningJobs.add(jobID)

                group.addTask {
                    await nextStep(
                        destination: grid.endPosition,
                        grid: grid,
                        isSlippery: isSlippery,
                        priorityQueue: priorityQueue,
                        results: results,
                        input: input
                    )

                    await runningJobs.remove(jobID)
                }
            }

            await group.waitForAll()
        }

        return await results.getValues()
    }

    private func shouldKeepLooping(priorityQueue: PriorityQueue<Input>, runningJobs: RunningJobs) async -> Bool {
        async let isRunningJobs = !runningJobs.getJobs().isEmpty
        async let outstandingQueue = !priorityQueue.isEmpty()
        return await [isRunningJobs, outstandingQueue].contains(true)
    }

    private func nextStep(
        destination: Coordinates,
        grid: DayGrid,
        isSlippery: Bool,
        priorityQueue: PriorityQueue<Input>,
        results: ResultsCache,
        input: Input
    ) async {
        guard let position = grid.getCoordinates(from: input.coordinates, direction: input.direction) else {
            preconditionFailure("Unexpected invalid position")
        }

        guard !input.history.contains(position) else {
            return
        }

        guard position != destination else {
            let finalCount = input.history.count + 1
            await results.add(finalCount)
            return
        }

        let nextPossibleDirections = [
            input.direction,
            input.direction.turnLeft,
            input.direction.turnRight,
        ]

        let directions: [CompassDirection] =
            switch grid[position]! {
            case .forest:
                preconditionFailure("Unexpected forrest")
            case .path:
                nextPossibleDirections
            case .slopeEast:
                isSlippery ? [.east] : nextPossibleDirections
            case .slopeNorth:
                isSlippery ? [.north] : nextPossibleDirections
            case .slopeSouth:
                isSlippery ? [.south] : nextPossibleDirections
            case .slopeWest:
                isSlippery ? [.west] : nextPossibleDirections
            }

        let validDirections = directions.filter {
            grid.getCoordinates(from: position, direction: $0) != nil
        }

        for direction in validDirections {
            await priorityQueue.push(input.next(coordinates: position, direction: direction))
        }

        return
    }
}

// MARK: - DayGrid

// The grid never changes, so making it class to save memory use in recursive function.
private class DayGrid {
    let endPosition: Coordinates
    let startingPosition: Coordinates

    private let grid: Grid<Coordinates, Value>

    init(data: String) {
        let grid = Grid<Coordinates, Value>(data: data)
        let yCoordinates = grid.values.keys.map(\.y)
        let maxY = yCoordinates.max()!
        let minY = yCoordinates.min()!
        endPosition = grid.values.keys.filter { $0.y == maxY }.first(where: { grid[$0] == .path })!
        startingPosition = grid.values.keys.filter { $0.y == minY }.first(where: { grid[$0] == .path })!

        self.grid = grid
    }

    subscript(key: Coordinates) -> Value? {
        get {
            grid[key]
        }
    }

    func getCoordinates(from: Coordinates, direction: CompassDirection) -> Coordinates? {
        guard
            let coordinates = grid.getCoordinates(from: from, direction: direction),
            self[coordinates] != .forest
        else {
            return nil
        }

        return coordinates
    }
}

// MARK: - Value

private enum Value: String, CaseIterable {
    case forest = "#"
    case path = "."
    case slopeEast = ">"
    case slopeNorth = "^"
    case slopeSouth = "v"
    case slopeWest = "<"
}

extension Value: CustomStringConvertible {
    var description: String {
        rawValue
    }
}

// MARK: - History

private struct History: Equatable {
    typealias Value = Coordinates

    var count: Int {
        values.count
    }

    private let values: [Value]

    init(values: [Value] = []) {
        self.values = values
    }

    func adding(coordinates: Coordinates) -> History {
        .init(values: values + [coordinates])
    }

    func contains(_ coordinates: Coordinates) -> Bool {
        values.first(where: { $0 == coordinates }) != nil
    }
}

// MARK: - Cache

private class ResultsCache {
    private var values: [Int] = []

    @MainActor
    func add(_ value: Int) async {
        if let max = values.max(), value > max {
            log("New high score: \(value)")
        }

        values.append(value)
    }

    @MainActor
    func getValues() async -> [Int] {
        values
    }
}

private class RunningJobs {
    private var values: [UUID] = []

    @MainActor
    func add(_ value: UUID) async {
        values.append(value)
    }

    @MainActor
    func getJobs() async -> [UUID] {
        values
    }

    @MainActor
    func remove(_ value: UUID) async {
        values = values.filter { $0 != value }
    }
}

// MARK: - Input

private struct Input: Comparable {
    let coordinates: Coordinates
    let direction: CompassDirection
    let history: History

    static func < (lhs: Input, rhs: Input) -> Bool {
        lhs.history.count > rhs.history.count
    }

    func next(coordinates: Coordinates, direction: CompassDirection) -> Input {
        .init(coordinates: coordinates, direction: direction, history: history.adding(coordinates: coordinates))
    }
}
