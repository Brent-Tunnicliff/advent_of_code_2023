// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day03: AdventDay {
    var data: String

    private var entities: [String] {
        data.split(separator: "\n").map {
            String($0)
        }
    }

    func part1() -> Any {
        let results = getValidNumbers(entities)
        return results.reduce(into: 0) { partialResult, result in
            partialResult += result.value
        }
    }

    func part2() -> Any {
        return getGearRatios(entities).reduce(into: 0) { partialResult, result in
            partialResult += result
        }
    }
}

private extension Day03 {
    typealias NumberResult = Result<[Int], Int>
    typealias SymbolResult = Result<Int, Character>

    struct Result<Index: Equatable, Value: Equatable>: Equatable {
        let columnIndex: Index
        let rowIndex: Int
        let value: Value
    }

    func getValidNumbers(_ lines: [String]) -> [NumberResult] {
        let (numbers, symbols) = map(lines: lines)
        return numbers.reduce(into: [NumberResult]()) { partialResult, number in
            for rowIndex in (number.rowIndex - 1...number.rowIndex + 1) {
                for columnIndex in (number.columnIndex.min()! - 1...number.columnIndex.max()! + 1) {
                    guard symbols.contains(columnIndex: columnIndex, rowIndex: rowIndex) else {
                        continue
                    }

                    partialResult.append(number)
                }
            }
        }
    }

    func getGearRatios(_ lines: [String]) -> [Int] {
        let (numbers, symbols) = map(lines: lines)
        return symbols.filter { $0.value == "*" }
            .reduce(into: [Int]()) { partialResult, result in
                var matchingNumbers: [NumberResult] = []

                for rowIndex in (result.rowIndex - 1...result.rowIndex + 1) {
                    for columnIndex in (result.columnIndex - 1...result.columnIndex + 1) {
                        guard
                            let number = numbers.matching(columnIndex: columnIndex, rowIndex: rowIndex),
                            !matchingNumbers.contains(where: { $0 == number })
                        else {
                            continue
                        }

                        matchingNumbers.append(number)
                    }
                }

                guard matchingNumbers.count == 2 else {
                    return
                }

                let ration = matchingNumbers.reduce(into: 0) { partialResult, result in
                    partialResult = [1, partialResult].max()! * result.value
                }

                partialResult.append(ration)
            }
    }

    func map(lines: [String]) -> ([NumberResult], [SymbolResult]) {
        lines
            .enumerated()
            .reduce(into: ([NumberResult](), [SymbolResult]())) { partialResult, line in
                let rowIndex = line.offset

                for character in line.element.enumerated() {
                    let columnIndex = character.offset

                    guard character.element != "." else {
                        continue
                    }

                    guard let number = character.element.wholeNumberValue else {
                        partialResult.1.append(
                            .init(
                                columnIndex: columnIndex,
                                rowIndex: rowIndex,
                                value: character.element
                            )
                        )
                        continue
                    }

                    guard
                        let lastResult = partialResult.0.last,
                        lastResult.rowIndex == rowIndex,
                        lastResult.columnIndex.contains(columnIndex - 1)
                    else {
                        partialResult.0.append(
                            .init(
                                columnIndex: [columnIndex],
                                rowIndex: rowIndex,
                                value: number
                            )
                        )
                        continue
                    }

                    let last = partialResult.0.popLast()!
                    let newColumnIndex = last.columnIndex + [columnIndex]
                    let newValue = Int("\(last.value)\(number)")!

                    partialResult.0.append(
                        .init(
                            columnIndex: newColumnIndex,
                            rowIndex: rowIndex,
                            value: newValue
                        )
                    )
                }
            }
    }
}

private extension Collection where Element == Day03.NumberResult {
    func matching(columnIndex: Int, rowIndex: Int) -> Element? {
        first(where: { $0.rowIndex == rowIndex && $0.columnIndex.contains(columnIndex) })
    }
}

private extension Collection where Element == Day03.SymbolResult {
    func contains(columnIndex: Int, rowIndex: Int) -> Bool {
        contains(where: { $0.rowIndex == rowIndex && $0.columnIndex == columnIndex })
    }
}
