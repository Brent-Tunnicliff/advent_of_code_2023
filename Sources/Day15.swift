// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation
import RegexBuilder

struct Day15: AdventDay {
    var data: String

    private var entities: [String] {
        data.replacingOccurrences(of: "\n", with: "")
            .split(separator: ",")
            .map { String($0) }
    }

    func part1() async -> Any {
        entities.reduce(into: 0) { partialTotalResult, text in
            let result = text.reduce(into: 0) { runningResult, character in
                let result = ((runningResult + Int(character.asciiValue!)) * 17) % 256
                runningResult = result
            }

            partialTotalResult += result
        }
    }

    func part2() async -> Any {
        "Not implemented"
    }
}
