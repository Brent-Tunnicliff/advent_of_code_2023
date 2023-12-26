// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

// Using Karger’s algorithm.
// see https://www.geeksforgeeks.org/introduction-and-implementation-of-kargers-algorithm-for-minimum-cut/
struct Day25: AdventDay {
    var data: String

    private var edges: Set<Edge> {
        data.split(separator: "\n").reduce(into: Set<Edge>()) { partialResult, row in
            let rowSplit = row.split(separator: ": ")
            precondition(rowSplit.count == 2)

            let component = Component(value: String(rowSplit[0]))
            let connections = rowSplit[1].split(separator: " ").map {
                precondition(!$0.isEmpty, "Unexpected empty result in '\(rowSplit[1])'")
                return Component(value: (String($0)))
            }

            precondition(!connections.contains(component), "Infinite loop present")

            for connection in connections {
                partialResult.insert(.init(from: min(component, connection), to: max(component, connection)))
            }
        }
    }

    func part1() async -> Any {
        let results = split(edges: edges)
        return results.0.count * results.1.count
    }

    func part2() async -> Any {
        "Not implemented"
    }

    private func split(edges: Set<Edge>) -> (Set<Component>, Set<Component>) {
        let components = edges.components
        let numberOfVertices = components.count
        var results: (Set<Component>, Set<Component>)?

        while results == nil {
            let subsets = Subset(
                values: components.reduce(into: [Component: Subset.Value]()) { partialResult, component in
                    partialResult[component] = .init(parent: component, rank: 0)
                }
            )

            var count = numberOfVertices
            while count > 2 {
                let edge = edges.randomElement()!
                let from = find(component: edge.from, in: subsets)
                let to = find(component: edge.to, in: subsets)

                guard from != to else {
                    continue
                }

                union(from, and: to, in: subsets)
                count -= 1
            }

            var cutEdges = 0
            for edge in edges {
                let from = find(component: edge.from, in: subsets)
                let to = find(component: edge.to, in: subsets)
                if from != to {
                    cutEdges += 1
                }
            }

            guard cutEdges == 3 else {
                log("Cut edges not 3")
                continue
            }

            let parents = subsets.all.filter {
                $0.key == $0.value.parent
            }.keys.map { $0 }

            precondition(parents.count == 2)

            let resultOne = getChildren(of: parents[0], in: subsets).union([parents[0]])
            let resultTwo = getChildren(of: parents[1], in: subsets).union([parents[1]])

            // Lets check if the sets are unique, and contain all the components.
            guard
                (resultOne.count + resultTwo.count) == numberOfVertices,
                resultOne.union(resultTwo).count == numberOfVertices
            else {
                log("Results not containing all")
                continue
            }

            results = (resultOne, resultTwo)
        }

        return results!
    }

    private func find(component: Component, in subset: Subset) -> Component {
        let matchingSubset = subset[component]

        if matchingSubset.parent != component {
            matchingSubset.parent = find(component: matchingSubset.parent, in: subset)
        }

        return matchingSubset.parent
    }

    private func union(_ first: Component, and other: Component, in subset: Subset) {
        let firstRoot = find(component: first, in: subset)
        let otherRoot = find(component: other, in: subset)

        guard subset[firstRoot].rank > subset[otherRoot].rank else {
            subset[firstRoot].parent = otherRoot
            return
        }

        guard subset[firstRoot].rank < subset[otherRoot].rank else {
            subset[otherRoot].parent = firstRoot
            return
        }

        subset[otherRoot].parent = firstRoot
        subset[firstRoot].rank += 1
    }

    private func getChildren(of component: Component, in subset: Subset) -> Set<Component> {
        let children = subset.all
            .filter { $0.key != component && $0.value.parent == component }
            .map { $0.key }

        let nestedChildren = children.reduce(into: Set<Component>()) { partialResult, child in
            partialResult.formUnion(
                getChildren(of: child, in: subset)
            )
        }

        return Set(children).union(nestedChildren)
    }
}

private struct Component: Hashable, Comparable {
    let value: String

    static func < (lhs: Component, rhs: Component) -> Bool {
        lhs.value < rhs.value
    }
}

private struct Edge: Hashable {
    let from: Component
    let to: Component
}

extension Set where Element == Edge {
    var components: Set<Component> {
        var components = Set<Component>()

        for connection in self {
            components.insert(connection.from)
            components.insert(connection.to)
        }

        return components
    }
}

private final class Subset {
    final class Value {
        var parent: Component
        var rank: Int

        init(parent: Component, rank: Int) {
            self.parent = parent
            self.rank = rank
        }
    }

    var all: [Component: Value] {
        values
    }

    private var values: [Component: Value]

    init(values: [Component: Value]) {
        self.values = values
    }

    subscript(key: Component) -> Value {
        values[key]!
    }
}
