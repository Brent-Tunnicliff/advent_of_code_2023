// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day13: AdventDay {
    var data: String

    var grids: [String] {
        data.split(separator: "\n\n")
            .map(String.init)
    }

    func part1() async -> Any {
        let grids = self.grids

        let results = await withTaskGroup(of: [Int].self) { group in
            for grid in grids {
                let columns = getColumns(for: grid)
                let rows = getRows(for: grid)

                group.addTask {
                    findMirrorPositions(for: columns)
                }

                group.addTask {
                    findMirrorPositions(for: rows).map { $0 * 100 }
                }
            }

            var results: [Int] = []
            for await result in group {
                results.append(contentsOf: result)
            }

            return results
        }

        let result = results.reduce(into: 0) { partialResult, value in
            partialResult += value
        }

        if !testsAreRunning {
            // Having lots of trouble with this one,
            // so checking against my submitted answers.
            precondition(result < 74304, "Answer is too high")
            precondition(result < 47817, "Answer is too high")
            precondition(result != 41857)
            precondition(result != 41861)
            precondition(result != 41863)
            precondition(result > 38217, "Answer is too low")
        }

        return result
    }

    func part2() async -> Any {
        "Not implemented"
    }

    private func getColumns(for grid: String) -> [String] {
        let rows = getRows(for: grid)
        let columns = rows.reduce(into: [Int: String]()) { partialResult, row in
            for (index, character) in row.enumerated() {
                let existingValue = partialResult[index] ?? ""
                partialResult[index] = existingValue + String(character)
            }
        }

        return columns.keys.sorted().map { columns[$0]! }
    }

    private func getRows(for grid: String) -> [String] {
        grid.split(separator: "\n")
            .map(String.init)
    }

    private func findMirrorPositions(for values: [String]) -> [Int] {
        getMatchingIndexes(for: values).compactMap { indexes in
            let startIndex = indexes.first
            let endIndex = indexes.last
            let difference = endIndex - startIndex
            for offset in (0...difference) {
                let forwardIndex = startIndex + offset
                let backwardIndex = endIndex - offset

                guard values[forwardIndex] == values[backwardIndex] else {
                    return nil
                }

                if forwardIndex + 1 == backwardIndex {
                    return forwardIndex + 1
                }
            }

            return nil
        }
    }

    private func getMatchingIndexes(for values: [String]) -> [(first: Int, last: Int)] {
        let matchingFirstIndex = getAllIndex(matching: values.first!, from: values).compactMap { index in
            index > values.startIndex ? (values.startIndex, index) : nil
        }

        let lastIndex = values.endIndex - 1
        let matchingLastIndex = getAllIndex(matching: values.last!, from: values).compactMap { index in
            index < lastIndex ? (index, lastIndex) : nil
        }

        let allIndex = (matchingFirstIndex + matchingLastIndex)
        let uniqueIndex = allIndex.reduce(into: [(first: Int, last: Int)]()) { partialResult, result in
            guard !partialResult.contains(where: { $0.first == result.0 && $0.last == result.1 }) else {
                return
            }

            partialResult.append(result)
        }

        return uniqueIndex
    }

    private func getAllIndex(matching value: String, from values: [String]) -> [Int] {
        guard let index = values.firstIndex(of: value) else {
            return []
        }

        let remainingValues = Array(values.dropFirst(index + 1))
        return [index] + getAllIndex(matching: value, from: remainingValues).map { $0 + index + 1 }
    }
}
