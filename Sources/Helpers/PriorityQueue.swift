// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation
import SwiftPriorityQueue

final class PriorityQueue<Value: Comparable> {
    private var queue = SwiftPriorityQueue.PriorityQueue<Value>()

    @MainActor
    func isEmpty() async -> Bool {
        queue.isEmpty
    }

    @MainActor
    func pop() async -> Value? {
        queue.pop()
    }

    @MainActor
    func push(_ value: Value) async {
        queue.push(value)
    }
}
