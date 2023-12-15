// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day04: AdventDay {
    var data: String

    private var cards: [Int: Card] {
        data.split(separator: "\n").reduce(into: [Int: Card]()) { partialResult, line in
            let card = Card(line: String(line))
            partialResult[card.id] = card
        }
    }

    func part1() -> Any {
        cards.values.reduce(
            into: 0,
            { partialResult, card in
                guard !card.matchingNumbers.isEmpty else {
                    return
                }

                let power = card.matchingNumbers.count - 1
                partialResult += max(1, calculatePower(2, power))
            }
        )
    }

    func part2() -> Any {
        // Brute force for da win!
        // This took 49 seconds to process on my machine.
        cards.values.reduce(
            into: [Card](),
            { partialResult, card in
                partialResult.append(card)
                partialResult.append(contentsOf: getWonCards(for: card))
            }
        ).count
    }

    private func calculatePower(_ base: Int, _ power: Int) -> Int {
        // Added this to it's own function because it is ugly and I want it to die.
        Int(pow(Double(base), Double(power)))
    }

    // Since cards always return the same winning values then lets cache them.
    private func getWonCards(for card: Card) -> [Card] {
        if let cachedResult = cachedCards[card] {
            return cachedResult
        }

        // I used this print command to make sure the program was still running haha.
        // print("Processing Card \(card.id)")

        let wonCards = card.matchingNumbers
            .enumerated()
            .compactMap { (index, _) in
                cards[card.id + 1 + index]
            }
            .reduce(into: [Card]()) { partialResult, card in
                partialResult.append(card)
                partialResult.append(contentsOf: getWonCards(for: card))
            }

        cachedCards[card] = wonCards
        return wonCards
    }
}

private var cachedCards: [Card: [Card]] = [:]

private struct Card: Hashable {
    let id: Int
    let numbers: [Int]
    let winningNumbers: [Int]

    /// Numbers that exist in both `numbers` and `winningNumbers`
    let matchingNumbers: [Int]

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

        let winningNumbers = allNumbers[0]
        let numbers = allNumbers[1]

        self.numbers = numbers
        self.matchingNumbers = numbers.filter { winningNumbers.contains($0) }
        self.winningNumbers = winningNumbers

    }

    private static func split(_ value: String, separator: String, expectedCount: Int? = nil) -> [String] {
        let result = value.split(separator: separator)
        guard expectedCount == nil || result.count == expectedCount else {
            fatalError("Unexpected count \(separator) for \(value)")
        }

        return result.map(String.init)
    }
}
