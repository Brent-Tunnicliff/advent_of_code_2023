// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day01: AdventDay {
    var data: String

    private var entities: [String] {
        data.split(separator: "\n").map {
            String($0)
        }
    }

    func part1() -> Any {
        entities.reduce(into: 0) { partialResult, entity in
            let digits = entity.compactMap {
                $0.wholeNumberValue
            }

            let first = digits.first ?? 0
            let last = digits.last ?? 0
            let newValue = Int("\(first)\(last)") ?? 0

            partialResult = partialResult + newValue
        }
    }

}
