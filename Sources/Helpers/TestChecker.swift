// Copyright © 2023 Brent Tunnicliff <btunnicliff.dev@gmail.com>

import Foundation

let testsAreRunning = ProcessInfo.processInfo.arguments.contains("TESTING")

let testsAreNotRunning = !testsAreRunning
