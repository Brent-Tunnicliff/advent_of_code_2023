// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day04: AdventDay {
    var data: String

    private var cards: [Card] {
        data.split(separator: "\n").map {
            Card(line: String($0))
        }
    }

    func part1() -> Any {
        cards.reduce(
            into: 0,
            { partialResult, card in
                let matchingNumbers = card.numbers.filter { card.winningNumbers.contains($0) }
                guard !matchingNumbers.isEmpty else {
                    return
                }

                let power = matchingNumbers.count - 1
                partialResult += max(1, calculatePower(2, power))
            }
        )
    }

    private func calculatePower(_ base: Int, _ power: Int) -> Int {
        // Added this to it's own function because it is ugly and I want it to die.
        Int(pow(Double(base), Double(power)))
    }
}

private struct Card {
    let id: Int
    let numbers: [Int]
    let winningNumbers: [Int]

    private static let cardSeparator = ": "
    private static let numberSeparator = " "
    private static let numbersTypeSeparator = " | "

    /// Expect format like `Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53`.
    init(line: String) {
        let card = Self.split(line, separator: Self.cardSeparator, expectedCount: 2)
        self.id = Int(card[0].trimmingPrefix("Card").trimmingCharacters(in: .whitespaces))!

        let allNumbers = Self.split(card[1], separator: Self.numbersTypeSeparator, expectedCount: 2).map { numbers in
            Self.split(numbers, separator: Self.numberSeparator).map { number in
                Int(number)!
            }
        }

        self.winningNumbers = allNumbers[0]
        self.numbers = allNumbers[1]
    }

    private static func split(_ value: String, separator: String, expectedCount: Int? = nil) -> [String] {
        let result = value.split(separator: separator)
        guard expectedCount == nil || result.count == expectedCount else {
            fatalError("Unexpected count \(separator) for \(value)")
        }

        return result.map(String.init)
    }
}
