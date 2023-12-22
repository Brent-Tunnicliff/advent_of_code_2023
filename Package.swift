// swift-tools-version: 5.9
import PackageDescription

let dependencies: [Target.Dependency] = [
    .product(name: "Algorithms", package: "swift-algorithms"),
    .product(name: "Collections", package: "swift-collections"),
    .product(name: "ArgumentParser", package: "swift-argument-parser"),
    .product(name: "SwiftPriorityQueue", package: "SwiftPriorityQueue")
]

let package = Package(
    name: "AdventOfCode",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            .upToNextMajor(from: "1.2.0")),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0")),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            .upToNextMajor(from: "1.2.0")),
        .package(
            url: "https://github.com/apple/swift-format.git",
            .upToNextMajor(from: "509.0.0")),
        .package(
            url: "https://github.com/Brent-Tunnicliff/swift-format-plugin", 
            .upToNextMajor(from: "1.0.0")
        ),
        .package(
            url: "https://github.com/davecom/SwiftPriorityQueue",
            .upToNextMajor(from: "1.4.0")
        ),
    ],
    targets: [
        .executableTarget(
            name: "AdventOfCode",
            dependencies: dependencies,
            resources: [.copy("Data")],
            plugins: [
                .plugin(name: "lint", package: "swift-format-plugin")
            ]
        ),
        .testTarget(
            name: "AdventOfCodeTests",
            dependencies: ["AdventOfCode"] + dependencies,
            plugins: [
                .plugin(name: "lint", package: "swift-format-plugin")
            ]
        )
    ]
)
