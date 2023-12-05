// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day05: AdventDay {
    var data: String

    private var entities: [String] {
        let values = data.split(separator: "\n\n").map(String.init)
        precondition(values.count == Section.count, "Unexpected values count \(values.count)")
        return values
    }

    func part1() async -> Any {
        async let seedValues = await mapSeedValues(from: entities[Section.seeds.rawValue])
        async let sections = await getSections()
        let seeds = await mapSeeds(seedValues, sections: sections)

        return seeds.min { left, right in
            left.location < right.location
        }!.location
    }

    private func mapSeedValues(from input: String) async -> [Int] {
        mapLine(input.trimmingPrefix(Section.seeds.prefix))
    }

    private func getSections() async -> [Section: RangeDictionary] {
        log("getSections start")

        // Lets map the following sections in parallel since last task was getting a bit long in runtime.
        var sections: [Section: RangeDictionary] = [:]
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

    private func mapLine(_ line: any StringProtocol) -> [Int] {
        line.split(separator: " ")
            .map { Int($0)! }
    }

    /// If there is no destination, then return the source value.
    private func map(source: Int, to destination: RangeDictionary?) -> Int {
        destination?[source] ?? source
    }

    private func mapSeeds(_ values: [Int], sections: [Section: RangeDictionary]) async -> [Seed] {
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
}

private enum Section: Int, CaseIterable {
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
}

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

private struct RangeDictionary {
    var dictionary: [Range<Int>: Range<Int>] = [:]

    subscript(key: Int) -> Int? {
        guard
            let matchingKey = dictionary.keys.first(where: { $0.contains(key) }),
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
            }

            dictionary[key] = newValue
        }
    }
}
