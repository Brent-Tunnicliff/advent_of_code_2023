// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

private let allowLogging = true

func log(_ message: String) {
    guard allowLogging else {
        return
    }

    print("\(Date().description): \(message)")
}
