// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation
import RegexBuilder

struct Day12: AdventDay {
    private let damaged: Character = "#"
    private let operational: Character = "."
    private let unknown: Character = "?"

    var data: String

    private var entities: [(key: [Int], row: String)] {
        data.split(separator: "\n").map { line in
            let split = line.split(separator: " ")
            let row = String(split[0])
            let key = split[1]
                .split(separator: ",")
                .map { Int($0)! }

            return (key, row)
        }
    }

    func part1() async -> Any {
        entities.reduce(into: 0) { partialResult, entity in
            partialResult += countWays(row: entity.row, key: entity.key)
        }
    }

    func part2() async -> Any {
        unfold(entities: entities).reduce(into: 0) { partialResult, entity in
            partialResult += countWays(row: entity.row, key: entity.key)
        }
    }

    // Found solution here https://www.reddit.com/r/adventofcode/comments/18ge41g/comment/kd09kvj/
    private static var countWaysCache = Cache<CacheKey, Int>()
    private func countWays(row: String, key: [Int]) -> Int {
        let cacheKey = CacheKey(input: row, key: key)
        if let cachedValue = Self.countWaysCache[cacheKey] {
            return cachedValue
        }

        let cacheAndReturn: (Int) -> Int = {
            Self.countWaysCache[cacheKey] = $0
            return $0
        }

        guard !row.isEmpty else {
            return cacheAndReturn(key.isEmpty ? 1 : 0)
        }

        guard !key.isEmpty else {
            for character in row where character == damaged {
                return cacheAndReturn(0)
            }

            return cacheAndReturn(1)
        }

        if row.count < (sum(key) + key.count - 1) {
            // The line is not long enough for all runs
            return cacheAndReturn(0)
        }

        guard row.first != operational else {
            return cacheAndReturn(
                countWays(row: String(row.dropFirst()), key: key)
            )
        }

        guard row.first == damaged else {
            // Otherwise dunno first spot, pick
            return cacheAndReturn(
                countWays(row: "\(damaged)\(row.dropFirst())", key: key)
                    + countWays(row: "\(operational)\(row.dropFirst())", key: key)
            )
        }

        let firstKey = key.first!
        let leftoverKey = key.dropFirst()
        for index in (0..<firstKey) where index < row.count && row.dropFirst(index).first == operational {
            return cacheAndReturn(0)
        }

        if firstKey < row.count, row.dropFirst(firstKey).first == damaged {
            return cacheAndReturn(0)
        }

        return cacheAndReturn(
            countWays(row: String(row.dropFirst(firstKey + 1)), key: Array(leftoverKey))
        )
    }

    private func sum(_ key: [Int]) -> Int {
        key.reduce(into: 0) { partialResult, value in
            partialResult += value
        }
    }

    func unfold(entities: [(key: [Int], row: String)]) -> [(key: [Int], row: String)] {
        entities.reduce(into: [(key: [Int], row: String)]()) { partialResult, entity in
            var key = entity.key
            var row = entity.row

            for _ in (0..<4) {
                key.append(contentsOf: entity.key)
                row += "?\(entity.row)"
            }

            partialResult.append((key, row))
        }
    }
}

private struct CacheKey: Hashable {
    let input: String
    let key: [Int]
}
