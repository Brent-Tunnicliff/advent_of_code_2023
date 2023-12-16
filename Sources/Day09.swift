// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day09: AdventDay {
    var data: String

    private var entities: [[Int]] {
        data.split(separator: "\n")
            .map {
                $0.split(separator: " ")
                    .map { Int($0)! }
            }
    }

    func part1() async -> Any {
        addingNextNumbers(for: getNumbers()).reduce(into: 0) { partialResult, numbers in
            partialResult += numbers.last!.value
        }
    }

    func part2() async -> Any {
        addingPreviousNumbers(for: getNumbers()).reduce(into: 0) { partialResult, numbers in
            partialResult += numbers.first!.value
        }
    }

    private func getNumbers() -> [[Number]] {
        entities.reduce(into: [[Number]]()) { partialTotalResult, row in
            let numbers = row.map(Number.init).reduce(into: [Number]()) { partialResult, current in
                guard let previous = partialResult.last else {
                    partialResult.append(current)
                    return
                }

                current.previous = previous
                partialResult.append(current)
            }

            injectChildren(into: numbers)
            precondition(
                numbers.first!.previous == nil && numbers.last!.next == nil,
                "numbers not ordered correctly"
            )

            partialTotalResult.append(numbers)
        }
    }

    private func addingNextNumbers(for allNumbers: [[Number]]) -> [[Number]] {
        allNumbers.reduce(into: [[Number]]()) { partialResult, numbers in
            let lastNumber = numbers.last!
            let nextNumber = getNextValue(from: lastNumber)
            nextNumber.previous = lastNumber

            injectChildren(into: [lastNumber, nextNumber])

            partialResult.append(numbers + [nextNumber])
        }
    }

    private func getNextValue(from number: Number) -> Number {
        var currentNumber: Number? = number
        var value = number.value
        while currentNumber != nil {
            let previousChild = currentNumber!.previousChild
            value = value + (previousChild?.value ?? 0)
            currentNumber = previousChild
        }

        return .init(value: value)
    }

    private func addingPreviousNumbers(for allNumbers: [[Number]]) -> [[Number]] {
        allNumbers.reduce(into: [[Number]]()) { partialResult, numbers in
            let firstNumber = numbers.first!
            let previousNumber = getPreviousValue(from: firstNumber)
            firstNumber.previous = previousNumber

            injectChildren(into: [previousNumber, firstNumber])

            partialResult.append([previousNumber] + numbers)
        }
    }

    private func getPreviousValue(from number: Number) -> Number {
        var currentNumber: Number? = getLowestNextChild(of: number)
        var value = currentNumber!.value
        while currentNumber != nil {
            guard let previousParent = currentNumber!.previousParent else {
                currentNumber = nil
                continue
            }

            value = previousParent.value - value
            currentNumber = previousParent
        }

        return .init(value: value)
    }

    private func getLowestNextChild(of number: Number) -> Number {
        guard let child = number.nextChild else {
            return number
        }

        return getLowestNextChild(of: child)
    }

    private func injectChildren(into numbers: [Number]) {
        let children = numbers.enumerated().reduce(into: [Number]()) { partialResult, number in
            let index = number.offset
            let currentNumber = number.element

            // Skip the first value.
            guard index > 0 else {
                return
            }

            let previousNumber = numbers[index - 1]
            let child = Number(value: currentNumber.value - previousNumber.value)
            currentNumber.previousChild = child
            previousNumber.nextChild = child
            partialResult.append(child)
        }

        let nonZeroChildren = children.filter { $0.value != 0 }
        guard nonZeroChildren.count > 0 else {
            return
        }

        // Continue generating for the next level until we get something like:
        //  0   3   6   9  12  15
        //    3   3   3   3   3
        //      0   0   0   0
        injectChildren(into: children)
    }
}

private class Number {
    let value: Int

    var nextChild: Number? {
        didSet {
            nextChild?.previousParent = self
        }
    }

    var previous: Number? = nil {
        didSet {
            previous?.next = self
        }
    }

    var previousChild: Number? {
        didSet {
            previousChild?.nextParent = self
        }
    }

    private(set) var next: Number? = nil
    private(set) var nextParent: Number?
    private(set) var previousParent: Number?

    init(value: Int) {
        self.value = value
    }
}
