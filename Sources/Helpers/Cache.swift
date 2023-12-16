// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

final class Cache<Key: Hashable, Value> {
    private var values: [Key: Value] = [:]

    func object(for key: Key) async -> Value? {
        await MainActor.run {
            values[key]
        }
    }

    func set(_ value: Value?, for key: Key) async {
        await MainActor.run {
            values[key] = value
        }
    }
}
