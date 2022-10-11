// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SpriteSheetAsset",
  platforms: [
    .macOS(.v11)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "SpriteSheetAsset",
      targets: ["SpriteSheetAsset"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(path: "../CompositeImageAsset"),
    .package(path: "../UniqueIdentifierProvider"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "SpriteSheetAsset",
      dependencies: [
        .product(name: "CompositeImageAsset", package: "CompositeImageAsset"),
        .product(name: "UniqueIdentifierProvider", package: "UniqueIdentifierProvider"),
      ]),
    .testTarget(
      name: "SpriteSheetAssetTests",
      dependencies: ["SpriteSheetAsset"]),
  ]
)
