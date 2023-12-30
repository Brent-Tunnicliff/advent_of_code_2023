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
                group.addTask {
                    getValues(grid: grid)
                }
            }

            var results = 0
            for await result in group {
                let newValue = result.reduce(into: 0) { partialResult, value in
                    partialResult += value
                }

                results += newValue
            }

            return results
        }

        if testsAreNotRunning {
            // Having lots of trouble with this one,
            // so checking against my submitted answers.
            precondition(results < 74304, "Answer is too high")
            precondition(results < 47817, "Answer is too high")
            precondition(results != 41857)
            precondition(results != 41861)
            precondition(results != 41863)
            precondition(results > 38217, "Answer is too low")
        }

        return results
    }

    func part2() async -> Any {
        let grids = self.grids

        return await withTaskGroup(of: [Int].self) { group in
            for grid in grids {
                group.addTask {
                    let partOneValues = getValues(grid: grid)

                    for index in (0..<grid.count) {
                        let characterToReplace = grid.dropFirst(index).first
                        guard characterToReplace != "\n" else {
                            continue
                        }

                        let newCharacter = characterToReplace == "#" ? "." : "#"

                        let start = grid.dropLast(grid.count - index)
                        let end = grid.dropFirst(index + 1)

                        let newValues = getValues(grid: start + newCharacter + end)

                        guard !newValues.isEmpty, newValues != partOneValues else {
                            continue
                        }

                        return newValues.filter {
                            !partOneValues.contains($0)
                        }
                    }

                    return []
                }
            }

            var results = 0
            for await result in group {
                let newValue = result.reduce(into: 0) { partialResult, value in
                    partialResult += value
                }

                results += newValue
            }

            return results
        }
    }

    private func getValues(grid: String) -> [Int] {
        let columns = getColumns(for: grid)
        let rows = getRows(for: grid)

        return findMirrorPositions(for: columns) + findMirrorPositions(for: rows).map { $0 * 100 }
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
