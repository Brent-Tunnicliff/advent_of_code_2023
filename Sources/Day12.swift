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
        var result = 0
        let filteredEntities = entities.filter(isPossible)
        for (index, entity) in filteredEntities.enumerated() {
            log("\(index + 1) of \(filteredEntities.count) start")
            result += getAllPossibleVariants(for: entity.row, key: entity.key).count
        }

        return result
    }

    func part2() async -> Any {
        "Not implemented"
    }

    private struct CacheKey: Hashable {
        let input: String
        let key: [Int]
    }

    private static var getAllPossibleVariantsCache: [CacheKey: [String]] = [:]
    private func getAllPossibleVariants(for row: String, key: [Int]) -> [String] {
        let cacheKey = CacheKey(input: row, key: key)
        if let cachedResult = Self.getAllPossibleVariantsCache[cacheKey] {
            return cachedResult
        }

        guard let firstIndex = Array(row).firstIndex(of: unknown) else {
            let value: [String] = [row].filter { isPossible(key: key, row: $0) }
            Self.getAllPossibleVariantsCache[cacheKey] = value
            return value
        }

        let result = [damaged, operational].reduce(into: [String]()) { partialResult, newCharacter in
            let editedRow = row.inserting(newCharacter, at: firstIndex)
            for variant in getAllPossibleVariants(for: editedRow, key: key) {
                partialResult.append(variant)
            }
        }

        Self.getAllPossibleVariantsCache[cacheKey] = result
        return result
    }

    private static var isPossibleCache: [CacheKey: Bool] = [:]
    private func isPossible(key: [Int], row: String) -> Bool {
        let cacheKey = CacheKey(input: row, key: key)
        if let cachedResult = Self.isPossibleCache[cacheKey] {
            return cachedResult
        }

        let lastIndex = key.count - 1
        let dynamicRegex: String = key.enumerated().reduce(into: "") { partialResult, item in
            let suffix = item.offset < lastIndex ? "[?.]+" : ""
            partialResult += "[?#]{\(item.element)}" + suffix
        }

        let range = NSRange(location: 0, length: row.utf16.count)
        let regex = try! NSRegularExpression(pattern: "^[.?]*\(dynamicRegex)[.?]*$")
        return regex.firstMatch(in: row, options: [], range: range) != nil
    }
}

private extension String {
    func inserting(_ value: Character, at index: Int) -> String {
        var newSelf = Array(self).map { String($0) }
        newSelf[index] = value.description
        return newSelf.joined()
    }
}
