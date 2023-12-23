// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

struct Day22: AdventDay {
    var data: String

    func part1() async -> Any {
        let result = createGrid()
            .getSafeToDisintegrateBricksCount()

        return result
    }

    func part2() async -> Any {
        let result = await createGrid()
            .getNumberOfChainReaction()

        if testsAreNotRunning {
            precondition(result > 13160, "13160 is too low")
            precondition(result > 14483, "14483 is too low")
            precondition(result > 36712, "36712 is too low")
            precondition(result != 77464)
            precondition(result != 83623)
        }

        return result
    }

    private func createGrid() -> DayGrid {
        let grid = data.split(separator: "\n").reduce(into: DayGrid()) { partialResult, row in
            let bounds: [[Int]] = row.split(separator: "~").map { bound in
                bound.split(separator: ",").map { value in
                    Int(String(value))!
                }
            }

            let lowerBoundValues = bounds[0]
            precondition(lowerBoundValues.count == 3, "Unexpected lowerBoundValues count \(lowerBoundValues)")

            let upperBoundValues = bounds[1]
            precondition(upperBoundValues.count == 3, "Unexpected upperBoundValues count \(upperBoundValues)")

            let lowerBound = ThreeDimensionalCoordinates(
                x: lowerBoundValues[0],
                y: lowerBoundValues[1],
                z: lowerBoundValues[2]
            )

            let upperBound = ThreeDimensionalCoordinates(
                x: upperBoundValues[0],
                y: upperBoundValues[1],
                z: upperBoundValues[2]
            )

            let key = lowerBound...upperBound
            partialResult[key] = String(row)
        }

        return settle(grid: grid)
    }

    private func settle(grid: DayGrid, z: Int = 0) -> DayGrid {
        guard z <= grid.keys.map(\.upperBound.z).max()! else {
            return grid
        }

        let bricksPerLevel = grid.keys.grouped(by: \.lowerBound.z)
        let nextZ = z + 1

        guard let bricks = bricksPerLevel[z] else {
            return settle(grid: grid, z: nextZ)
        }

        for brick in bricks {
            let overlappingBricksBelow = grid.keys.filter {
                $0.lowerBound.z < z && $0.overlaps(brick.twoDimensional)
            }

            let newLowerZ = (overlappingBricksBelow.map(\.upperBound.z).max() ?? 0) + 1
            guard newLowerZ != brick.lowerBound.z else {
                continue
            }

            let newPosition = brick.moved(to: newLowerZ)
            grid[newPosition] = grid[brick]
            grid[brick] = nil
        }

        return settle(grid: grid, z: nextZ)
    }
}

private typealias Brick = ClosedRange<ThreeDimensionalCoordinates>
private extension Brick {
    var twoDimensional: ClosedRange<Coordinates> {
        lowerBound.twoDimensional...upperBound.twoDimensional
    }

    func overlaps(_ other: ClosedRange<Coordinates>) -> Bool {
        xRange.overlaps(other.xRange) && yRange.overlaps(other.yRange)
    }

    func moved(to z: Int) -> Brick {
        let zDifference = upperBound.z - lowerBound.z
        let newLowerBound = ThreeDimensionalCoordinates(
            x: lowerBound.x,
            y: lowerBound.y,
            z: z
        )
        let newUpperBound = ThreeDimensionalCoordinates(
            x: upperBound.x,
            y: upperBound.y,
            z: z + zDifference
        )

        return newLowerBound...newUpperBound
    }
}

private extension ClosedRange where Bound: CoordinatesType {
    var xRange: ClosedRange<Int> {
        (lowerBound.x...upperBound.x)
    }

    var yRange: ClosedRange<Int> {
        (lowerBound.y...upperBound.y)
    }
}

private extension ClosedRange where Bound == ThreeDimensionalCoordinates {
    var zRange: ClosedRange<Int> {
        (lowerBound.z...upperBound.z)
    }
}

private class DayGrid {
    var keys: [Brick] {
        dictionary.keys.map { $0 }
    }

    private var dictionary: [Brick: String] = [:]

    subscript(key: Brick) -> String? {
        get {
            dictionary[key]
        }
        set {
            dictionary[key] = newValue
        }
    }

    func getSafeToDisintegrateBricksCount() -> Int {
        keys.count - getVitalBricks().count
    }

    func getNumberOfChainReaction() async -> Int {
        let vitalBricks = getVitalBricks().sorted(by: { $0.upperBound.z > $1.upperBound.z })
        return await withTaskGroup(of: Int.self) { group in
            for brick in vitalBricks {
                group.addTask { [unowned self] in
                    await self.getCollapsableBricks(above: brick, collapsing: Set([brick])).count - 1
                }
            }

            var results = 0
            for await result in group {
                precondition(result >= 0)
                results += result
            }
            return results
        }
    }

    private func getVitalBricks() -> [Brick] {
        keys.reduce(into: Set<Brick>()) { partialResult, brick in
            let bricksBeneath = getBricksBeneath(brick)

            guard bricksBeneath.count == 1 else {
                return
            }

            partialResult.insert(bricksBeneath.first!)
        }.map { $0 }
    }

    private func getBricksAbove(_ brick: Brick) -> [Brick] {
        keys.filter {
            $0.lowerBound.z == (brick.upperBound.z + 1) && $0.overlaps(brick.twoDimensional)
        }
    }

    private func getBricksBeneath(_ brick: Brick) -> [Brick] {
        keys.filter {
            $0.upperBound.z == (brick.lowerBound.z - 1) && $0.overlaps(brick.twoDimensional)
        }
    }

    private func getCollapsableBricks(above brick: Brick, collapsing: Set<Brick>) async -> Set<Brick> {
        log("\(brick): processing - \(self[brick]!)")

        let collapsableBricks = getBricksAbove(brick).reduce(into: [Brick]()) { partialResult, stackedBrick in
            let bricksBeneathStacked = getBricksBeneath(stackedBrick)
            guard bricksBeneathStacked.filter({ !collapsing.contains($0) }).isEmpty else {
                // Supported by a brick that is not collapsing.
                return
            }

            partialResult.append(stackedBrick)
        }

        precondition(!collapsableBricks.contains(brick))

        log("\(brick): collapsableBricks \(collapsableBricks.count)")
        log("\(brick): collapsableBricks \(collapsableBricks.first?.description ?? "nil")")

        var updatedCollapsing = collapsing.union(collapsableBricks)
        for stackedBrick in collapsableBricks {
            updatedCollapsing = await updatedCollapsing.union(
                getCollapsableBricks(
                    above: stackedBrick,
                    collapsing: updatedCollapsing
                )
            )
        }

        log("\(brick): returning calculated")
        return updatedCollapsing
    }
}

extension DayGrid: CustomStringConvertible {
    var description: String {
        keys.sorted(by: { $0.lowerBound.z < $1.lowerBound.z }).reduce(into: "") { partialResult, brick in
            partialResult += "\(brick): \(dictionary[brick]!)\n"
        }
    }
}
