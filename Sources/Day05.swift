// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

// Split part 1 and 2 into seperate extensions so them have clear separation and namespaces.
// This is because I had to rethink so much of the solution for part 2.
struct Day05: AdventDay {
    var data: String

    private var entities: [String] {
        let values = data.split(separator: "\n\n").map(String.init)
        precondition(values.count == Section.count, "Unexpected values count \(values.count)")
        return values
    }
}

// MARK: - Part 1

extension Day05 {
    private struct Seed {
        let fertilizer: Int
        let humidity: Int
        let id: Int
        let light: Int
        let location: Int
        let soil: Int
        let temperature: Int
        let water: Int
    }

    func part1() async -> Any {
        async let seedValues = mapSeedValues(from: entities[Section.seeds.rawValue])
        async let sections = getSections()
        let seeds = await mapSeeds(seedValues, sections: sections)

        let location = seeds.min { left, right in
            left.location < right.location
        }!.location

        return location
    }

    private func mapSeeds(_ values: [Int], sections: SectionMap) async -> [Seed] {
        log("mapSeeds start")

        var seeds: [Seed] = []
        // Process these concurrently too.
        await withTaskGroup(of: Seed.self) { group in
            for value in values {
                group.addTask {
                    log("Creating seed object \(value)")

                    let soil = map(source: value, to: sections[.seedToSoil])
                    let fertilizer = map(source: soil, to: sections[.soilToFertilizer])
                    let water = map(source: fertilizer, to: sections[.fertilizerToWater])
                    let light = map(source: water, to: sections[.waterToLight])
                    let temperature = map(source: light, to: sections[.lightToTemperature])
                    let humidity = map(source: temperature, to: sections[.temperatureToHumidity])
                    let location = map(source: humidity, to: sections[.humidityToLocation])

                    return Seed(
                        fertilizer: fertilizer,
                        humidity: humidity,
                        id: value,
                        light: light,
                        location: location,
                        soil: soil,
                        temperature: temperature,
                        water: water
                    )
                }
            }

            for await seed in group {
                seeds.append(seed)
            }
        }

        log("mapSeeds finished")
        return seeds
    }

    private func mapSeedValues(from input: String) async -> [Int] {
        mapLine(input.trimmingPrefix(Section.seeds.prefix))
    }

    /// If there is no destination, then return the source value.
    private func map(source: Int, to destination: RangeDictionary?) -> Int {
        destination?[source] ?? source
    }

    private typealias SectionMap = [Section: RangeDictionary]

    private struct RangeDictionary {
        private var dictionary: [Range<Int>: Range<Int>] = [:]

        var all: [(key: Range<Int>, value: Range<Int>)] {
            dictionary.map { $0 }
        }

        var keys: [Range<Int>] {
            dictionary.keys.map { $0 }
        }

        var values: [Range<Int>] {
            dictionary.values.map { $0 }
        }

        subscript(key: Int) -> Int? {
            guard
                let matchingKey = first(containing: key)?.key,
                let values = dictionary[matchingKey]
            else {
                log("key not found \(key)")
                return nil
            }

            // Convert the key index to the value index.
            let index = key - matchingKey.lowerBound + values.lowerBound

            return values[index]
        }

        subscript(key: Range<Int>) -> Range<Int>? {
            get {
                dictionary[key]
            }
            set {
                if let newValue {
                    precondition(
                        key.count == newValue.count,
                        "Key length \(key.count) and value length \(newValue.count) do not match for \(key) \(newValue)"
                    )

                    precondition(
                        dictionary.keys.first(where: { $0.overlaps(key) }) == nil,
                        "Key length \(key.count) and value length \(newValue.count) do not match for \(key) \(newValue)"
                    )
                }

                dictionary[key] = newValue
            }
        }

        func first(containing value: Int) -> (key: Range<Int>, value: Range<Int>)? {
            dictionary.first(where: { $0.key.containsValue(value) })
        }

        func nextAfter(_ value: Int) -> (key: Range<Int>, value: Range<Int>)? {
            guard let matchingKey = first(containing: value) else {
                return nil
            }

            let filteredDictionary = dictionary.filter {
                $0.key.lowerBound < matchingKey.key.lowerBound
            }

            return filteredDictionary.sorted { $0.key.lowerBound < $1.key.lowerBound }.first
        }

        /// Merges dictionaries, if key conflict will keep current.
        func merging(_ other: RangeDictionary) -> RangeDictionary {
            .init(
                dictionary: self.dictionary.merging(other.dictionary) { current, new in
                    precondition(
                        current == new, "Unexpected merging if \(current) and \(new)"
                    )

                    return current
                }
            )
        }

        func withPadding(from start: Int, to end: Int) -> RangeDictionary {
            all.sorted(by: { $0.key.lowerBound < $1.key.lowerBound })
                .enumerated()
                .reduce(into: (count: start, result: RangeDictionary())) { partialResult, entity in
                    let key = entity.element.key
                    if partialResult.count < key.lowerBound {
                        let padding = (partialResult.count..<key.lowerBound)
                        partialResult.result[padding] = padding
                    }

                    partialResult.result[key] = entity.element.value
                    partialResult.count = key.upperBound

                    if entity.offset + 1 == all.count, end != key.upperBound {
                        let padding = (key.upperBound..<end)
                        partialResult.result[padding] = padding
                    }
                }.result
        }
    }

    private func getSections() async -> SectionMap {
        log("getSections start")

        // Lets map the following sections in parallel since last task was getting a bit long in runtime.
        var sections: SectionMap = [:]
        await withTaskGroup(of: (Section, RangeDictionary).self) { group in
            // We already worked out seed, so ignore.
            for section in Section.allCases.filter({ $0 != .seeds }) {
                group.addTask {
                    log("getSections processing \(String(describing: section))")

                    return await (
                        section,
                        mapSectionRange(from: entities[section.rawValue], for: section)
                    )
                }
            }

            for await (section, map) in group {
                log("getSections completed \(String(describing: section))")
                sections[section] = map
            }
        }

        log("getSections end")
        return sections
    }

    private func mapSectionRange(from input: String, for section: Section) async -> RangeDictionary {
        input.trimmingPrefix(section.prefix)
            .split(separator: "\n")
            .map(mapLine)
            .reduce(into: RangeDictionary()) { partialResult, mapping in
                log("mapRange \(String(describing: section)) - \(mapping)")

                precondition(
                    mapping.count == 3,
                    "Unexpected mapping count \(mapping.count) for \(String(describing: section))"
                )

                let destinationRangeStart = mapping[0]
                let sourceRangeStart = mapping[1]
                let rangeLength = mapping[2]
                let destinationRangeEnd = destinationRangeStart + rangeLength
                let sourceRangeEnd = sourceRangeStart + rangeLength

                let destinationRange = (destinationRangeStart..<destinationRangeEnd)
                let sourceRange = (sourceRangeStart..<sourceRangeEnd)
                partialResult[sourceRange] = destinationRange
            }
    }
}

// MARK: - Part 2

extension Day05 {
    private class Node {
        let children: [Node]
        let value: Range<Int>
        let section: Section

        init(children: [Node], value: Range<Int>, section: Section) {
            self.children = children
            self.section = section
            self.value = value
        }

        var minValue: Int {
            children.min(by: { $0.minValue < $1.minValue })?.minValue ?? value.lowerBound
        }
    }

    func part2() async -> Any {
        let sections = await getSections()
        let seedRanges = mapLine(entities[Section.seeds.rawValue].trimmingPrefix(Section.seeds.prefix))
            .chunks(ofCount: 2)
            .map {
                let start = $0.first!
                let end = start + $0.last!
                return (start..<end)
            }

        let seedNodes = seedRanges.map { seedRange in
            Node(
                children: createNodeChildren(for: .seeds, with: seedRange, from: sections),
                value: seedRange,
                section: .seeds
            )
        }

        return seedNodes.map(\.minValue).min()!
    }

    private func createNodeChildren(for section: Section, with range: Range<Int>, from sections: SectionMap) -> [Node] {
        guard let currentSection = section.next else {
            return []
        }

        let overlappingKeys = sections[currentSection]!.all.compactMap {
            getOverlappingRange(of: range, overlapping: $0)
        }

        let paddedValues: [Node] = getPadding(overlappingKeys, from: range.lowerBound, to: range.upperBound)
            .compactMap {
                let value = $0.value
                let children = createNodeChildren(
                    for: currentSection,
                    with: value,
                    from: sections
                )

                guard currentSection.isLast || !children.isEmpty else {
                    return nil
                }

                return .init(children: children, value: value, section: currentSection)
            }

        let expectedRangeCountOfChildren = range.upperBound - range.lowerBound
        let combinedRangeCountOfChildren = paddedValues.reduce(into: 0) { partialResult, node in
            partialResult += node.value.upperBound - node.value.lowerBound
        }

        precondition(
            combinedRangeCountOfChildren == expectedRangeCountOfChildren,
            """
            Unexpected number of children for range \(range), \
            got \(combinedRangeCountOfChildren), \
            expected \(expectedRangeCountOfChildren)
            """
        )

        return paddedValues
    }

    private func getOverlappingRange(
        of key: Range<Int>,
        overlapping other: (key: Range<Int>, value: Range<Int>)
    ) -> (key: Range<Int>, value: Range<Int>)? {
        guard key.overlaps(other.key) else {
            return nil
        }

        let overlappedKeys = key.clamped(to: other.key)

        let offset = overlappedKeys.lowerBound - other.key.lowerBound
        let count = overlappedKeys.upperBound - overlappedKeys.lowerBound
        let valueStart = other.value.lowerBound + offset
        let valueEnd = valueStart + count
        let overlappedValues = (valueStart..<valueEnd)

        return (overlappedKeys, overlappedValues)
    }

    private func getPadding(
        _ range: [(key: Range<Int>, value: Range<Int>)],
        from start: Int,
        to end: Int
    ) -> [(key: Range<Int>, value: Range<Int>)] {
        guard !range.isEmpty else {
            let padding = start..<end
            return [(padding, padding)]
        }

        let sortedRange = range.sorted(by: { $0.key.lowerBound < $1.key.lowerBound })
        let paddedValues = sortedRange.reduce(into: [(key: Range<Int>, value: Range<Int>)]()) { partialResult, item in
            let previousUpperBound = partialResult.last?.key.upperBound ?? start

            if previousUpperBound < item.key.lowerBound {
                let padding = (previousUpperBound..<item.key.lowerBound)
                partialResult.append((padding, padding))
            }

            partialResult.append(item)

            if item == sortedRange.last!, item.key.upperBound < end {
                let padding = (item.key.upperBound..<end)
                partialResult.append((padding, padding))
            }

            precondition(
                partialResult.last!.key.upperBound <= end,
                "Unexpected range \(partialResult.last!.key.upperBound) < \(end)"
            )
        }

        let expectedRangeCountOfChildren = end - start
        let combinedRangeCountOfChildren = paddedValues.reduce(into: 0) { partialResult, node in
            partialResult += node.value.upperBound - node.value.lowerBound
        }

        precondition(
            combinedRangeCountOfChildren == expectedRangeCountOfChildren,
            """
            Unexpected number of children for range \(start..<end), \
            got \(combinedRangeCountOfChildren), \
            expected \(expectedRangeCountOfChildren)
            """
        )

        return paddedValues
    }
}

// MARK: - Common

private extension Day05 {

    enum Section: Int, CaseIterable, Comparable {
        case seeds = 0
        case seedToSoil
        case soilToFertilizer
        case fertilizerToWater
        case waterToLight
        case lightToTemperature
        case temperatureToHumidity
        case humidityToLocation

        static var count: Int {
            Self.allCases.count
        }

        var isLast: Bool {
            next == nil
        }

        var next: Section? {
            Section(rawValue: rawValue + 1)
        }

        var prefix: String {
            switch self {
            case .seeds:
                "seeds: "
            case .seedToSoil:
                "seed-to-soil map:\n"
            case .soilToFertilizer:
                "soil-to-fertilizer map:\n"
            case .fertilizerToWater:
                "fertilizer-to-water map:\n"
            case .waterToLight:
                "water-to-light map:\n"
            case .lightToTemperature:
                "light-to-temperature map:\n"
            case .temperatureToHumidity:
                "temperature-to-humidity map:\n"
            case .humidityToLocation:
                "humidity-to-location map:\n"
            }
        }

        static func < (lhs: Day05.Section, rhs: Day05.Section) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    func mapLine(_ line: any StringProtocol) -> [Int] {
        line.split(separator: " ")
            .map { Int($0)! }
    }
}

private extension Range where Bound: Comparable {
    /// Range extends ` Collection`, and when calling `contains(:)` to first converts the itself into an array.
    /// For this project that has huge performance implications.
    /// So  compare to the lower and upper bounds instead.
    func containsValue(_ value: Bound) -> Bool {
        lowerBound <= value && upperBound > value
    }
}

private extension Collection where Element == Range<Int> {
    var min: Element? {
        self.min {
            $0.lowerBound < $1.lowerBound
        }
    }
}
