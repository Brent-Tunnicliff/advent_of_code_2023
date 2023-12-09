// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day07: AdventDay {
    var data: String

    func part1() -> Any {
        getTotalWinnings(includeJoker: false)
    }

    func part2() -> Any {
        getTotalWinnings(includeJoker: true)
    }

    private func getTotalWinnings(includeJoker: Bool) -> Int {
        getHands(includeJoker: includeJoker).sorted().reversed().enumerated().reduce(into: 0) { partialResult, hand in
            partialResult += hand.element.bid * (hand.offset + 1)
        }
    }

    private func getHands(includeJoker: Bool) -> [Hand] {
        data.split(separator: "\n")
            .map {
                $0.trimmingCharacters(in: .whitespaces).split(separator: " ")
            }
            .map { line in
                precondition(line.count == 2, "Unexpected line count \(line)")

                let bid = Int(line[1])!
                let cards = line[0].map {
                    Card(rawValue: $0.description, includeJoker: includeJoker)
                }

                return Hand(bid: bid, cards: cards)
            }
    }
}

/// Is of type `Int` to represent the card strength..
private enum Card: Int, Comparable {
    case ace = 0
    case king
    case queen
    case jack
    case ten
    case nine
    case eight
    case seven
    case six
    case five
    case four
    case three
    case two
    case joker

    init(rawValue: String, includeJoker: Bool) {
        self =
            switch rawValue {
            case "A": .ace
            case "K": .king
            case "Q": .queen
            case "J": includeJoker ? .joker : .jack
            case "T": .ten
            case "9": .nine
            case "8": .eight
            case "7": .seven
            case "6": .six
            case "5": .five
            case "4": .four
            case "3": .three
            case "2": .two
            default:
                preconditionFailure("Unexpected card \(rawValue)")
            }
    }

    static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Is of type `Int` to represent the hand strength.
private enum HandType: Int, Comparable {
    case fiveOfAKind = 0
    case fourOfAKind
    case fullHouse
    case threeOfAKind
    case twoPair
    case onePair
    case highCard

    static func < (lhs: HandType, rhs: HandType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

private struct Hand: Comparable {
    let bid: Int
    let cards: [Card]
    let type: HandType

    init(bid: Int, cards: [Card]) {
        precondition(cards.count == 5, "Unexpected cards count \(cards)")

        self.bid = bid
        self.cards = cards

        let groupedCards = cards.sorted().reduce(into: [Card: Int]()) { partialResult, card in
            let cardsToIncrement = card == .joker ? Array(partialResult.keys) : [card]

            for cardToIncrement in cardsToIncrement {
                let existingCount = partialResult[cardToIncrement] ?? 0
                partialResult[cardToIncrement] = existingCount + 1
            }
        }.map { $0 }

        precondition(!groupedCards.contains(where: { $0.key == .joker }), "Unexpected joker in \(groupedCards)")

        type =
            switch groupedCards.count {
            // If 0 then they must all be joker.
            case 0: .fiveOfAKind
            case 1: .fiveOfAKind
            case 2:
                if groupedCards.first(where: { $0.value == 4 }) != nil {
                    .fourOfAKind
                } else {
                    .fullHouse
                }
            case 3:
                if groupedCards.first(where: { $0.value == 3 }) != nil {
                    .threeOfAKind
                } else {
                    .twoPair
                }
            case 4: .onePair
            case 5: .highCard
            default:
                preconditionFailure("Unexpected groupedCards \(groupedCards)")
            }
    }

    static func < (lhs: Hand, rhs: Hand) -> Bool {
        guard lhs.type == rhs.type else {
            return lhs.type < rhs.type
        }

        for index in 0..<5 {
            let lhsCard = lhs.cards[index]
            let rhsCard = rhs.cards[index]

            guard lhsCard != rhsCard else {
                continue
            }

            return lhsCard < rhsCard
        }

        preconditionFailure("Unexpected end of loop comparing \(lhs.cards) and \(rhs.cards)")
    }
}
