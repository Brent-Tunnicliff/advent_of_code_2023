// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

// Found the below solutions after getting hints from forums.
//  - https://forums.swift.org/t/advent-of-code-2023/68749/41
//  - https://www.reddit.com/r/adventofcode/comments/18df7px/2023_day_8_solutions/
//      - I was making sure to only read some comments and ignored solution posts, as I wanted to work this out.
//  - https://stackoverflow.com/a/28352004
//
// Man, day 8 beat me, I would not have gotten it without the above help.
// But that is what being a software engineer is all about, our sources :)

func lcm(_ vector: [Int]) -> Int {
    vector.reduce(1, lcm)
}

func lcm(a: Int, b: Int) -> Int {
    (a / gcd(a, b)) * b
}

func gcd(_ a: Int, _ b: Int) -> Int {
    var (a, b) = (a, b)
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return abs(a)
}
