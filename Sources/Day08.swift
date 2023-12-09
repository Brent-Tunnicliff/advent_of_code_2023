// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day08: AdventDay {
    var data: String

    func part1() async -> Any {
        let entities = getEntities()
        let startingNode = entities.map.first(where: { $0.key == "AAA" })!.value
        let directions = entities.directions.map { $0 }

        return await getNumberOfStepsTakenToProgressThroughMap(
            map: entities.map,
            directions: directions,
            targetNode: "ZZZ",
            currentCount: 0,
            currentNode: startingNode,
            directionsRemaining: directions
        )
    }

    func part2() async -> Any {
        "Not Implemented"
    }

    private typealias Node = (left: String, right: String)
    private typealias MapNodes = [String: Node]
    private func getEntities() -> (directions: String, map: MapNodes) {
        let values = data.split(separator: "\n\n").map(String.init)
        precondition(values.count == 2, "Unexpected values count \(values.count)")

        let directions = values[0]
        let map = values[1].split(separator: "\n").reduce(into: MapNodes()) { partialResult, line in
            let lineSplit = line.split(separator: " = ")
            precondition(lineSplit.count == 2, "Unexpected line count \(lineSplit.count)")

            let name = String(lineSplit[0])
            let nextPaths = lineSplit[1].trimmingCharacters(in: .init(charactersIn: "("...")"))
                .split(separator: ", ")
                .map { String($0) }

            precondition(nextPaths.count == 2, "Unexpected nextPaths count \(nextPaths.count)")

            partialResult[name] = (nextPaths[0], nextPaths[1])
        }

        return (directions, map)
    }

    private func getNumberOfStepsTakenToProgressThroughMap(
        map: MapNodes,
        directions: [Character],
        targetNode: String,
        currentCount: Int,
        currentNode: Node,
        directionsRemaining: [Character]
    ) async -> Int {
        // Needed to use async because after x amount of time of running on main thread it was being terminated.
        await Task {
            let nextCount = currentCount + 1
            let nextDirection = directionsRemaining[0]
            let nextLocation = nextDirection == "L" ? currentNode.left : currentNode.right

            guard nextLocation != targetNode else {
                return nextCount
            }

            let editedDirectionsRemaining = Array(directionsRemaining.dropFirst())
            let nextDirectionsRemaining = editedDirectionsRemaining.count > 0 ? editedDirectionsRemaining : directions

            return await getNumberOfStepsTakenToProgressThroughMap(
                map: map,
                directions: directions,
                targetNode: targetNode,
                currentCount: nextCount,
                currentNode: map[nextLocation]!,
                directionsRemaining: nextDirectionsRemaining
            )
        }.value
    }
}
