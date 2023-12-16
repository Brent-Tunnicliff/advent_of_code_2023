// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

private let allowLogging = false

func log(_ message: String) {
    guard allowLogging else {
        return
    }

    print("\(Date().description): \(message)")
}
