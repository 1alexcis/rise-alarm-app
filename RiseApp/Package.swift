// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RiseApp",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "RiseApp", targets: ["RiseApp"]),
    ],
    targets: [
        .target(
            name: "RiseApp",
            path: "RiseApp",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "RiseAppTests",
            dependencies: ["RiseApp"],
            path: "RiseAppTests"
        ),
    ]
)
