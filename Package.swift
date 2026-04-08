// swift-tools-version: 5.9
// Tooling package for SPM-only dependencies (e.g. SnapshotTesting). The iOS app remains the Xcode project under LearnHappyGerman/.
import PackageDescription

let package = Package(
    name: "LearningHappyGermanSnapshots",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "LearningHappyGermanSnapshots", targets: ["LearningHappyGermanSnapshots"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0")
    ],
    targets: [
        .target(
            name: "LearningHappyGermanSnapshots",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Sources/LearningHappyGermanSnapshots"
        )
    ]
)
