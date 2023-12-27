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
            partialTotalResult += hash(for: text)
        }
    }

    func part2() async -> Any {
        let boxes = entities.reduce(into: [Int: [DayBox]]()) { partialTotalResult, text in
            let command = getCommand(text)
            let box = hash(for: command.label)
            switch command.type {
            case let .add(value):
                partialTotalResult.add(box: .init(label: command.label, focalLength: value), for: box)
            case .remove:
                partialTotalResult.removeBox(command.label, for: box)
            }
        }

        return boxes.reduce(into: 0) { partialResult, box in
            for (index, value) in box.value.enumerated() {
                partialResult += (box.key + 1) * (index + 1) * value.focalLength
            }
        }
    }

    private func hash(for input: String) -> Int {
        input.reduce(into: 0) { runningResult, character in
            runningResult = ((runningResult + Int(character.asciiValue!)) * 17) % 256
        }
    }

    private func getCommand(_ input: String) -> (label: String, type: CommandType) {
        if input.contains("-") {
            return (String(input.dropLast()), .remove)
        }

        let components = input.split(separator: "=")
        let label = String(components[0])
        let value = Int(components[1])!
        return (label, .add(value))
    }
}

private enum CommandType {
    case add(Int)
    case remove
}

private struct DayBox {
    let label: String
    let focalLength: Int
}

private extension Dictionary where Key == Int, Value == [DayBox] {
    mutating func removeBox(_ label: String, for key: Key) {
        self[key] = self[key]?.filter { $0.label != label }
    }

    mutating func add(box: DayBox, for key: Key) {
        let boxes = self[key] ?? []
        guard boxes.contains(where: { $0.label == box.label }) else {
            self[key] = boxes + [box]
            return
        }

        self[key] = boxes.map {
            guard $0.label == box.label else {
                return $0
            }

            return box
        }
    }
}
