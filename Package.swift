// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Swift-iOS-App",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "App", targets: ["App"])
    ],
    targets: [
        .target(name: "App", path: "Sources/App"),
        .testTarget(name: "AppTests", dependencies: ["App"], path: "Tests")
    ]
)
