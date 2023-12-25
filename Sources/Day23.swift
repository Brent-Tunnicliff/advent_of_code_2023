// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day23: AdventDay {
    var data: String

    func part1() async -> Any {
        await getPathLengths(isSlippery: true).max()!
    }

    // Brute force won!
    // Took 38676.250664541 seconds, whoops haha
    // I don't understand how others in Reddit did brute force and took like 10 minutes.
    // What did I do wrong?
    func part2() async -> Any {
        await getPathLengths(isSlippery: false).max()!
    }

    func getPathLengths(isSlippery: Bool) async -> [Int] {
        let grid = DayGrid(data: data)
        let intersectingPaths = await getIntersectionPaths(grid: grid, isSlippery: isSlippery)
        let starting = await intersectingPaths.first(from: grid.startingPosition)!.getValues().from
        let ending = await intersectingPaths.first(to: grid.endPosition)!.getValues().to

        return await traverseIntersections(
            currentPosition: starting,
            count: 0,
            destination: ending,
            history: .init()
        )
    }

    private func getIntersectionPaths(grid: DayGrid, isSlippery: Bool) async -> [IntersectionPath] {
        let intersections = grid.getIntersections()
        return await withTaskGroup(of: Optional<IntersectionPath>.self) { group in
            for intersection in intersections {
                let intersectionValues = await intersection.getValues()
                for direction in intersectionValues.directions {
                    group.addTask {
                        let nextIntersection = await mapPathToNextIntersection(
                            from: intersectionValues.coordinates,
                            direction: direction,
                            intersections: intersections,
                            grid: grid,
                            count: 0,
                            isSlippery: isSlippery,
                            history: .init(values: [intersectionValues.coordinates])
                        )

                        guard let nextIntersection else {
                            return nil
                        }

                        return await IntersectionPath(
                            from: intersection,
                            to: nextIntersection.intersection,
                            distance: nextIntersection.count
                        )
                    }
                }
            }

            var results: [IntersectionPath] = []
            for await result in group where result != nil {
                results.append(result!)
            }

            return results
        }
    }

    private typealias MapPathToNextIntersectionResult = (intersection: Intersection, count: Int)?
    private func mapPathToNextIntersection(
        from: Coordinates,
        direction: CompassDirection,
        intersections: [Intersection],
        grid: DayGrid,
        count: Int,
        isSlippery: Bool,
        history: History<Coordinates>
    ) async -> MapPathToNextIntersectionResult {
        guard let position = grid.getCoordinates(from: from, direction: direction) else {
            preconditionFailure("Unexpected invalid position")
        }

        guard await !history.contains(position) else {
            return nil
        }

        if let intersection = await intersections.first(containing: position) {
            return (intersection, count + 1)
        }

        let nextPossibleDirections = [
            direction,
            direction.turnLeft,
            direction.turnRight,
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

        let nextDirection = directions.first {
            grid.getCoordinates(from: position, direction: $0) != nil
        }

        guard let nextDirection else {
            return nil
        }

        return await mapPathToNextIntersection(
            from: position,
            direction: nextDirection,
            intersections: intersections,
            grid: grid,
            count: count + 1,
            isSlippery: isSlippery,
            history: history.adding(value: position)
        )
    }

    private func traverseIntersections(
        currentPosition: Intersection,
        count: Int,
        destination: Intersection,
        history: History<IntersectionPath>
    ) async -> [Int] {
        let currentPositionValues = await currentPosition.getValues()
        let destinationValues = await destination.getValues()
        guard currentPositionValues.coordinates != destinationValues.coordinates else {
            log("Path discovered: \(count)")
            return [count]
        }

        return await withTaskGroup(of: [Int].self) { group in
            for path in currentPositionValues.paths where await path.getValues().from.equals(other: currentPosition) {
                group.addTask {
                    guard await !history.contains(path) else {
                        return []
                    }

                    let pathValues = await path.getValues()
                    return await traverseIntersections(
                        currentPosition: pathValues.to,
                        count: count + pathValues.distance,
                        destination: destination,
                        history: history.adding(value: path)
                    )
                }
            }

            var results: [Int] = []
            for await result in group {
                results.append(contentsOf: result)
            }

            return results
        }
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

    func getIntersections() -> [Intersection] {
        grid.values
            .compactMap { entity in
                guard entity.value != .forest else {
                    return nil
                }

                let directions = CompassDirection.allCases.filter {
                    getCoordinates(from: entity.key, direction: $0) != nil
                }

                guard directions.count > 2 else {
                    return nil
                }

                return Intersection(coordinates: entity.key, directions: directions, value: entity.value)
            } + getStartAndEndAsIntersections()
    }

    private func getStartAndEndAsIntersections() -> [Intersection] {
        [
            Intersection(coordinates: startingPosition, directions: [.south], value: grid[startingPosition]!),
            Intersection(coordinates: endPosition, directions: [], value: grid[endPosition]!),
        ]
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

private struct History<Value> {
    private let values: [Value]

    init(values: [Value] = []) {
        self.values = values
    }

    func adding(value: Value) -> History {
        .init(values: values + [value])
    }
}

extension History where Value: Equatable {
    @MainActor
    func contains(_ value: Value) async -> Bool {
        values.contains(where: { $0 == value })
    }
}

extension History where Value == IntersectionPath {
    @MainActor
    func contains(_ other: IntersectionPath) async -> Bool {
        guard await !values.contains(path: other) else {
            return false
        }

        guard await values.contains(intersection: await other.getValues().to) else {
            return false
        }

        return true
    }
}

// MARK: - Intersection

private class Intersection {
    struct Values {
        let coordinates: Coordinates
        let directions: [CompassDirection]
        var paths: [IntersectionPath]
        let value: Value
    }

    private var values: Intersection.Values

    init(coordinates: Coordinates, directions: [CompassDirection], paths: [IntersectionPath] = [], value: Value) {
        self.values = .init(
            coordinates: coordinates,
            directions: directions,
            paths: paths,
            value: value
        )
    }

    @MainActor
    func add(path newPath: IntersectionPath) async {
        values = .init(
            coordinates: values.coordinates,
            directions: values.directions,
            paths: values.paths + [newPath],
            value: values.value
        )
    }

    @MainActor
    func contains(_ coordinates: Coordinates) async -> Bool {
        values.coordinates == coordinates
    }

    @MainActor
    func equals(other: Intersection) async -> Bool {
        await other.getValues().coordinates == self.values.coordinates
    }

    @MainActor
    func getValues() async -> Intersection.Values {
        values
    }
}

private extension Collection where Element == Intersection {
    @MainActor
    func first(containing coordinates: Coordinates) async -> Intersection? {
        for intersection in self where await intersection.contains(coordinates) {
            return intersection
        }

        return nil
    }
}

// MARK: - IntersectionPath

private class IntersectionPath {
    struct Values {
        let from: Intersection
        let to: Intersection
        let distance: Int
    }

    private let values: IntersectionPath.Values

    init(from: Intersection, to: Intersection, distance: Int) async {
        self.values = .init(
            from: from,
            to: to,
            distance: distance
        )

        await from.add(path: self)
        await to.add(path: self)
    }

    @MainActor
    func getValues() async -> IntersectionPath.Values {
        values
    }

    @MainActor
    func equals(_ other: IntersectionPath) async -> Bool {
        let otherValues = await other.getValues()
        async let checks = [
            values.to.equals(other: otherValues.to),
            values.from.equals(other: otherValues.from),
        ]

        return await checks.filter { $0 }.count == checks.count
    }
}

private extension Collection where Element == IntersectionPath {
    @MainActor
    func contains(path: IntersectionPath) async -> Bool {
        for intersection in self where await intersection.equals(path) {
            return true
        }

        return false
    }

    @MainActor
    func contains(intersection: Intersection) async -> Bool {
        let values = await intersection.getValues()
        guard await first(from: values.coordinates) == nil else {
            return true
        }

        guard await first(to: values.coordinates) == nil else {
            return true
        }

        return false
    }

    @MainActor
    func first(from coordinates: Coordinates) async -> IntersectionPath? {
        for intersection in self {
            let values = await intersection.getValues()
            if await values.from.contains(coordinates) {
                return intersection
            }
        }

        return nil
    }

    @MainActor
    func first(to coordinates: Coordinates) async -> IntersectionPath? {
        for intersection in self {
            let values = await intersection.getValues()
            if await values.to.contains(coordinates) {
                return intersection
            }
        }

        return nil
    }
}
