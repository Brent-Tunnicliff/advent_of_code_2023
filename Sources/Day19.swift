// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation
import RegexBuilder

struct Day19: AdventDay {
    var data: String

    func part1() async -> Any {
        getAccepted(parts: getParts(), using: getWorkFlows()).reduce(into: 0) { partialResult, part in
            partialResult += part.aerodynamic + part.extremelyCoolLooking + part.musical + part.shiny
        }
    }

    func part2() async -> Any {
        "Not implemented"
    }

    private func getWorkFlows() -> [WorkflowId: [Rule]] {
        let workFlows = getDataRows(section: 0).reduce(into: [WorkflowId: [Rule]]()) { partialResult, row in
            let splitRow = row.trimmingCharacters(in: ["}"]).split(separator: "{")
            let workflowId = String(splitRow[0])

            precondition(partialResult[workflowId] == nil, "Unexpected repeat for \(workflowId)")

            let mapResult: (String) -> Result = {
                switch $0 {
                case "A": .accept
                case "R": .reject
                default: .workflow($0)
                }
            }

            let rules = splitRow[1].split(separator: ",").reduce(into: [Rule]()) { partialResult, rule in
                guard rule.contains(":") else {
                    partialResult.append(FallbackRule(result: mapResult(String(rule))))
                    return
                }

                let component: Component = rule.first.map {
                    switch $0 {
                    case "a": .aerodynamic
                    case "x": .extremelyCoolLooking
                    case "m": .musical
                    case "s": .shiny
                    default: preconditionFailure("Unexpected component \($0)")
                    }
                }!

                let conditionValue = Int(String(rule.dropFirst(2).split(separator: ":")[0]))!
                let condition: RuleCondition = rule.dropFirst().first.map {
                    switch $0 {
                    case ">": .greaterThan(conditionValue)
                    case "<": .lessThan(conditionValue)
                    default: preconditionFailure("Unexpected condition \($0)")
                    }
                }!

                let result = rule.dropFirst(2).split(separator: ":")[1]

                partialResult.append(
                    ConditionalRule(
                        partComponent: component,
                        condition: condition,
                        result: mapResult(String(result))
                    )
                )
            }

            partialResult[workflowId] = rules
        }

        for rules in workFlows.values {
            for rule in rules {
                guard case let .workflow(workFlowId) = rule.result else {
                    continue
                }

                precondition(workFlows.keys.contains(workFlowId), "Unexpected work flow \(workFlowId)")
            }
        }

        return workFlows
    }

    private func getParts() -> [Part] {
        getDataRows(section: 1).reduce(into: [Part]()) { partialResult, row in
            let components = row.trimmingCharacters(in: ["{", "}"]).split(separator: ",")
            let valueFor: (String) -> Int = { component in
                Int(components.first(where: { $0.contains(component) })!.trimmingPrefix("\(component)="))!
            }

            partialResult.append(
                .init(
                    aerodynamic: valueFor("a"),
                    extremelyCoolLooking: valueFor("x"),
                    musical: valueFor("m"),
                    shiny: valueFor("s")
                )
            )
        }
    }

    private func getDataRows(section: Int) -> [String] {
        data.split(separator: "\n\n")[section].split(separator: "\n").map {
            String($0)
        }
    }

    private func getAccepted(parts: [Part], using workflows: [WorkflowId: [Rule]]) -> [Part] {
        let startingRules = workflows["in"]!
        return parts.filter {
            process(rules: startingRules, for: $0, using: workflows)
        }
    }

    private func process(rules: [Rule], for part: Part, using workflows: [WorkflowId: [Rule]]) -> Bool {
        let currentRule = rules.first!

        guard currentRule is FallbackRule == false else {
            return process(result: currentRule.result, for: part, using: workflows)
        }

        let rule = currentRule as! ConditionalRule
        let meetsCondition: Bool =
            switch rule.condition {
            case let .greaterThan(value):
                part.value(for: rule.partComponent) > value
            case let .lessThan(value):
                part.value(for: rule.partComponent) < value
            }

        guard !meetsCondition else {
            return process(result: currentRule.result, for: part, using: workflows)
        }

        return process(rules: Array(rules.dropFirst()), for: part, using: workflows)
    }

    private func process(result: Result, for part: Part, using workflows: [WorkflowId: [Rule]]) -> Bool {
        switch result {
        case .accept:
            true
        case .reject:
            false
        case let .workflow(workflowId):
            process(rules: workflows[workflowId]!, for: part, using: workflows)
        }
    }
}

private class Part {
    let aerodynamic: Int
    let extremelyCoolLooking: Int
    let musical: Int
    let shiny: Int

    init(aerodynamic: Int, extremelyCoolLooking: Int, musical: Int, shiny: Int) {
        self.aerodynamic = aerodynamic
        self.extremelyCoolLooking = extremelyCoolLooking
        self.musical = musical
        self.shiny = shiny
    }

    func value(for component: Component) -> Int {
        switch component {
        case .aerodynamic:
            self.aerodynamic
        case .extremelyCoolLooking:
            self.extremelyCoolLooking
        case .musical:
            self.musical
        case .shiny:
            self.shiny
        }
    }
}

private typealias WorkflowId = String

private enum Component {
    case aerodynamic
    case extremelyCoolLooking
    case musical
    case shiny
}

private enum RuleCondition {
    case greaterThan(Int)
    case lessThan(Int)
}

private enum Result {
    case accept
    case reject
    case workflow(WorkflowId)
}

private protocol Rule {
    var result: Result { get }
}

private class ConditionalRule: Rule {
    let partComponent: Component
    let condition: RuleCondition
    let result: Result

    init(partComponent: Component, condition: RuleCondition, result: Result) {
        self.partComponent = partComponent
        self.condition = condition
        self.result = result
    }
}

private class FallbackRule: Rule {
    let result: Result

    init(result: Result) {
        self.result = result
    }
}
