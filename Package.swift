// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UrbitAtom",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "UrbitAtom",
            targets: ["UrbitAtom"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.3.1"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
            .package(url: "https://github.com/daisuke-t-jp/MurmurHash-Swift", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "UrbitAtom",
            dependencies: [
                "BigInt",
                .product(name: "MurmurHash-Swift", package: "MurmurHash-Swift"),
               .product(name: "Parsing", package: "swift-parsing")
            ]
        ),
        .testTarget(
            name: "UrbitAtomTests",
            dependencies: ["UrbitAtom"]),
    ]
)
