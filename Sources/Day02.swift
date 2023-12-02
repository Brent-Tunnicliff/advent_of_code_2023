// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day02: AdventDay {
    var data: String

    private var entities: [String] {
        data.split(separator: "\n").map {
            String($0)
        }
    }

    func part1() -> Any {
        entities
            .map(Game.init)
            .filter(\.isValid)
            .reduce(into: 0) { partialResult, game in
                partialResult += game.number
            }
    }

    func part2() -> Any {
        entities
            .map(Game.init)
            .reduce(into: 0) { partialResult, game in
                let blue = game.sets.map(\.blue).max() ?? 0
                let green = game.sets.map(\.green).max() ?? 0
                let red = game.sets.map(\.red).max() ?? 0

                partialResult += blue * green * red
            }
    }
}

private struct Game {
    let isValid: Bool
    let number: Int
    let sets: [Game.Set]

    /// Expected format `Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green`
    init(game: String) {
        let gameSeparator = ": "
        let gameSplit = game.split(separator: gameSeparator)
        guard gameSplit.count == 2 else {
            fatalError("Unexpected format using split '\(gameSeparator)', \(game)")
        }

        let gameNumber = gameSplit[0].trimmingPrefix("Game ")
        guard let number = Int(gameNumber) else {
            fatalError("Unexpected game number \(gameNumber), \(game)")
        }

        self.number = number
        self.sets = gameSplit[1].split(separator: "; ").map { set in
            let cubes = set.split(separator: ", ").map {
                String($0)
            }

            return Game.Set(
                blue: Self.getCube(cubes, matching: "blue"),
                green: Self.getCube(cubes, matching: "green"),
                red: Self.getCube(cubes, matching: "red")
            )
        }

        self.isValid = sets.filter { !$0.isValid }.isEmpty
    }

    private static func getCube(_ values: [String], matching: String) -> Int {
        let number = values.first { $0.lowercased().contains(matching) }?.split(separator: " ").first
        guard let number, let value = Int(number) else {
            return 0
        }

        return value
    }
}

extension Game {
    struct Set {
        let blue: Int
        let isValid: Bool
        let green: Int
        let red: Int

        init(blue: Int, green: Int, red: Int) {
            self.blue = blue
            self.green = green
            self.red = red

            self.isValid = blue <= Max.blue
                && green <= Max.green
                && red <= Max.red
        }
    }
}

extension Game.Set {
    enum Max {
        static let blue = 14
        static let green = 13
        static let red = 12
    }
}
