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
        let validNumbers = getValidNumbers(entities)
        return validNumbers.reduce(into: 0) { partialResult, value in
            partialResult += value
        }
    }
}

private extension Day03 {
    typealias NumberResult = Result<[Int], Int>
    typealias SymbolResult = Result<Int, Character>

    struct Result<Index, Value> {
        let columnIndex: Index
        let rowIndex: Int
        let value: Value
    }

    func getValidNumbers(_ lines: [String]) -> [Int] {
        let (numbers, symbols) = lines
            .enumerated()
            .reduce(into: ([NumberResult](), [SymbolResult]())) { partialResult, line in
                let rowIndex = line.offset

                line.element.enumerated().forEach { character in
                    let columnIndex = character.offset

                    guard character.element != "." else {
                        return
                    }

                    guard let number = character.element.wholeNumberValue else {
                        partialResult.1.append(.init(
                            columnIndex: columnIndex,
                            rowIndex: rowIndex,
                            value: character.element
                        ))
                        return
                    }

                    guard
                        let lastResult = partialResult.0.last,
                        lastResult.rowIndex == rowIndex,
                        lastResult.columnIndex.contains(columnIndex-1)
                    else {
                        partialResult.0.append(.init(
                            columnIndex: [columnIndex],
                            rowIndex: rowIndex,
                            value: number
                        ))
                        return
                    }

                    let last = partialResult.0.popLast()!
                    let newColumnIndex = last.columnIndex + [columnIndex]
                    let newValue = Int("\(last.value)\(number)")!

                    partialResult.0.append(.init(
                        columnIndex: newColumnIndex,
                        rowIndex: rowIndex,
                        value: newValue
                    ))
                }
            }

        return numbers.reduce(into: [Int]()) { partialResult, number in
            (number.rowIndex-1...number.rowIndex+1).forEach { (rowIndex: Int) in
                (number.columnIndex.min()!-1...number.columnIndex.max()!+1).forEach { (columnIndex: Int) in
                    guard symbols.contains(columnIndex: columnIndex, rowIndex: rowIndex) else {
                        return
                    }

                    partialResult.append(number.value)
                }
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
