// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "agtCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "agtCore", targets: ["agtCore"]),
        .executable(name: "agtctl", targets: ["agtctl"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(name: "agtCore"),
        .testTarget(name: "agtCoreTests", dependencies: ["agtCore"]),
        .target(
            name: "agtctlKit",
            dependencies: [
                "agtCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(name: "agtctl", dependencies: ["agtctlKit"]),
        .testTarget(name: "agtctlKitTests", dependencies: ["agtctlKit"]),
    ],
    swiftLanguageModes: [.v6]
)
