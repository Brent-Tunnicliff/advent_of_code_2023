// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day20: AdventDay {
    private static let machineModule = MachineModule(name: "rx")

    var data: String

    func part1() async -> Any {
        let modules = getModules()
        var history: [PulseResult] = []
        var count = 0
        let countMax = 1000
        while count < countMax {
            let result = pressButton(with: modules)
            count += 1

            guard history.contains(result) else {
                history.append(result)
                continue
            }

            history.append(result)

            guard let repeatIndex = detectRepeatPattern(within: history) else {
                continue
            }

            var newHistory = history.dropFirst(repeatIndex + 1)
            if history.count + newHistory.count > countMax {
                newHistory = newHistory.dropLast(newHistory.count - (countMax - newHistory.count - 1))
            }

            history.append(contentsOf: newHistory)
            count += newHistory.count
        }

        precondition(history.count == 1000)

        let combined = history.reduce(into: (high: 0, low: 0)) { partialResult, result in
            partialResult.high += result.high
            partialResult.low += result.low
        }

        return combined.high * combined.low
    }

    func part2() async -> Any {
        let modules = getModules()
        _ = pressButton(with: modules)

        var lowValues: [ModuleIdentifier: Int] = [:]
        for index in 1...10_000 {
            _ = pressButton(with: modules)

            for record in Self.machineModule.history {
                let module = record.history.last!
                guard module.pulse == .high, lowValues[module.input] == nil else {
                    continue
                }

                lowValues[module.input] = index + 1
            }

            if lowValues.keys.count == 4 {
                break
            }
        }

        let result = lcm(Array(lowValues.values))

        if testsAreNotRunning {
            precondition(result > 1_298_120_819_400, "1298120819400 is too low")
            precondition(result > 246_064_974_629_760, "246064974629760 is too low")
        }

        return result
    }

    private func detectRepeatPattern(within history: [PulseResult]) -> Int? {
        let indexes = history.enumerated()
            .filter {
                $0.element == history.last!
            }
            .map {
                $0.offset
            }
            .dropLast()

        guard indexes.count > 1 else {
            return nil
        }

        let firstIndex = indexes[0]
        let firstLoop = history.dropFirst(firstIndex).dropLast(history.count - indexes[1])

        let lastLoop = history.dropFirst(indexes.last! + 1)
        guard firstLoop == lastLoop else {
            return nil
        }

        return firstIndex
    }

    // MARK: - Setup

    private func getModules() -> Modules {
        let modules: Modules = data.split(separator: "\n")
            .reduce(into: [Self.machineModule.name: Self.machineModule]) { partialResult, row in
                let split = row.split(separator: " -> ")

                precondition(split.count == 2)

                let destinations = split[1].split(separator: ", ").map { String($0) }

                precondition(destinations.count > 0)

                let module = String(split[0])
                guard module != "broadcaster" else {
                    partialResult[module] = BroadcastModule(name: module, destinations: destinations)
                    return
                }

                let moduleType = module.first!
                let moduleName = String(module.dropFirst())

                switch moduleType {
                case "&":
                    partialResult[moduleName] = ConjunctionModule(name: moduleName, destinations: destinations)
                case "%":
                    partialResult[moduleName] = FlipFlopModule(name: moduleName, destinations: destinations)
                default:
                    preconditionFailure("Unexpected module type '\(moduleType)'")
                }
            }

        registerConjunctionModuleInputs(modules)

        return modules
    }

    private func registerConjunctionModuleInputs(_ modules: Modules) {
        let conjunctionModules: [ConjunctionModule] = modules.compactMap {
            guard let module = $0.value as? ConjunctionModule else {
                return nil
            }

            return module
        }

        for conjunctionModule in conjunctionModules {
            let inputs = modules.filter { $0.value.destinations.contains(conjunctionModule.name) }.keys
            conjunctionModule.register(inputs: Array(inputs))
        }
    }

    // MARK: - Processing

    private func pressButton(with modules: Modules) -> PulseResult {
        Self.machineModule.reset()

        var lowResult = 0
        var highResult = 0
        var sendPending: [SendPulse] = [.init(pulse: .low, input: "start", destination: "broadcaster", history: [])]

        while !sendPending.isEmpty {
            let sendPulse = sendPending.first!
            sendPending = Array(sendPending.dropFirst())

            switch sendPulse.pulse {
            case .high:
                highResult += 1
            case .low:
                lowResult += 1
            }

            guard let destination = modules[sendPulse.destination] else {
                continue
            }

            sendPending.append(contentsOf: destination.receive(pulse: sendPulse))
        }

        return .init(low: lowResult, high: highResult)
    }
}

// MARK: - Pulse

private enum Pulse {
    case high
    case low
}

private struct SendPulse {
    let pulse: Pulse
    let input: ModuleIdentifier
    let destination: ModuleIdentifier
    let history: [SendPulse]
}

private struct PulseResult: Equatable {
    let low: Int
    let high: Int
}

// MARK: - Module

private typealias ModuleIdentifier = String
private typealias Modules = [ModuleIdentifier: ModuleType]

private protocol ModuleType {
    var destinations: [ModuleIdentifier] { get }
    var name: ModuleIdentifier { get }

    func receive(pulse sentPulse: SendPulse) -> [SendPulse]
}

extension ModuleType {
    func getNext(pulse: Pulse, sentPulse: SendPulse) -> [SendPulse] {
        destinations.map {
            .init(pulse: pulse, input: name, destination: $0, history: sentPulse.history + [sentPulse])
        }
    }
}

// MARK: - BroadcastModule

private class BroadcastModule: ModuleType {
    let destinations: [ModuleIdentifier]
    let name: ModuleIdentifier

    init(name: ModuleIdentifier, destinations: [ModuleIdentifier]) {
        self.name = name
        self.destinations = destinations
    }

    // MARK: - ModuleType

    func receive(pulse sentPulse: SendPulse) -> [SendPulse] {
        getNext(pulse: sentPulse.pulse, sentPulse: sentPulse)
    }
}

// MARK: - ConjunctionModule

private class ConjunctionModule: ModuleType {
    let destinations: [ModuleIdentifier]
    let name: ModuleIdentifier

    private var memory: [ModuleIdentifier: Pulse] = [:]

    init(name: ModuleIdentifier, destinations: [ModuleIdentifier]) {
        self.name = name
        self.destinations = destinations
    }

    func register(inputs: [ModuleIdentifier]) {
        for input in inputs {
            memory[input] = .low
        }
    }

    // MARK: - ModuleType

    func receive(pulse sentPulse: SendPulse) -> [SendPulse] {
        memory[sentPulse.input] = sentPulse.pulse
        let allInputsSentHigh = memory.values.filter({ $0 == .low }).isEmpty

        let nextPulse: Pulse = allInputsSentHigh ? .low : .high

        return getNext(pulse: nextPulse, sentPulse: sentPulse)
    }
}

// MARK: - FlipFlopModule

private class FlipFlopModule: ModuleType {
    let destinations: [ModuleIdentifier]
    let name: ModuleIdentifier

    private var isOn: Bool = false

    init(name: ModuleIdentifier, destinations: [ModuleIdentifier]) {
        self.destinations = destinations
        self.name = name
    }

    // MARK: - ModuleType

    func receive(pulse sentPulse: SendPulse) -> [SendPulse] {
        switch sentPulse.pulse {
        case .high:
            return []
        case .low:
            break
        }

        isOn.toggle()

        let nextPulse: Pulse = isOn ? .high : .low

        return getNext(pulse: nextPulse, sentPulse: sentPulse)
    }
}

// MARK: - MachineModule

private class MachineModule: ModuleType {
    let destinations: [ModuleIdentifier] = []
    let name: ModuleIdentifier

    private(set) var history: [SendPulse] = []

    init(name: ModuleIdentifier) {
        self.name = name
    }

    // MARK: - ModuleType

    func receive(pulse sentPulse: SendPulse) -> [SendPulse] {
        history.append(sentPulse)
        return []
    }

    func reset() {
        history = []
    }
}
