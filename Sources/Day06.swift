// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation
import RegexBuilder

struct Day06: AdventDay {
    var data: String

    func part1() -> Any {
        return getGames()
            .map(getNumberOfWinningOptions)
            .reduce(into: 1) { partialResult, number in
                partialResult = partialResult * number
            }
    }

    func part2() -> Any {
        return "Not implemented"
    }
}

private extension Day06 {
    typealias Game = (time: Int, distance: Int)

    func getGames() -> [Game] {
        let values = data.split(separator: "\n")
            .map { process(line: String($0)) }

        precondition(values.count == 2)
        precondition(values[0].count == values[1].count)

        return values[0].enumerated().reduce(into: [Game]()) { partialResult, time in
            partialResult.append((time.element, values[1][time.offset]))
        }
    }

    func process(line: String) -> [Int] {
        line.split(separator: Regex { OneOrMore(.whitespace) })
            .dropFirst()
            .map {
                Int($0)!
            }
    }

    func getNumberOfWinningOptions(for game: Game) -> Int {
        let firstWinnable = (0...game.time)
            .enumerated()
            .first {
                checkIfWin($0.element, limit: game.time, toBeat: game.distance)
            }

        guard let firstWinnable else {
            return 0
        }

        return (game.time + 1) - firstWinnable.offset * 2
    }

    private func checkIfWin(_ timeCharged: Int, limit: Int, toBeat targetDistance: Int) -> Bool {
        precondition(timeCharged <= limit)
        let remainingTime = limit - timeCharged
        let distance = remainingTime * timeCharged
        return distance > targetDistance
    }
}
