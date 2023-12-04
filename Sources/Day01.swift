// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day01: AdventDay {
    var data: String

    private var entities: [String] {
        data.split(separator: "\n").map {
            String($0)
        }
    }

    private let namedDigits = [
        "one": 1,
        "two": 2,
        "three": 3,
        "four": 4,
        "five": 5,
        "six": 6,
        "seven": 7,
        "eight": 8,
        "nine": 9,
    ]

    func part1() -> Any {
        entities.reduce(into: 0) { partialResult, entity in
            let digits = entity.compactMap {
                $0.wholeNumberValue
            }

            let first = digits.first ?? 0
            let last = digits.last ?? 0
            let newValue = Int("\(first)\(last)") ?? 0

            partialResult += newValue
        }
    }

    func part2() -> Any {
        return entities.reduce(into: 0) { partialResult, entity in
            let first = getDigit(entity, getKey: { $0.min() }) ?? 0
            let last = getDigit(entity, getKey: { $0.max() }) ?? 0
            let newValue = Int("\(first)\(last)") ?? 0

            partialResult = partialResult + newValue
        }
    }

    private func getDigit(_ string: String, getKey: (([Int]) -> Int?)) -> Int? {
        // Map the value to the index it starts on.
        // Got solution from https://stackoverflow.com/a/58462061.
        var values = namedDigits.reduce(into: [Int: Int]()) { partialResult, item in
            let ranges = string.ranges(of: item.key)
            guard !ranges.isEmpty else {
                // No match
                return
            }

            for range in ranges {
                let index = string.distance(from: string.startIndex, to: range.lowerBound)
                partialResult[index] = item.value
            }
        }

        // Now applying all digits to the same index:value map.
        // This should not overwrite any values as namedDigit keys only contain letters, not digits.
        for (offset, element) in string.enumerated() {
            if let wholeNumberValue = element.wholeNumberValue {
                values[offset] = wholeNumberValue
            }
        }

        guard let key = getKey(Array(values.keys)) else {
            return nil
        }

        return values[key]
    }
}
