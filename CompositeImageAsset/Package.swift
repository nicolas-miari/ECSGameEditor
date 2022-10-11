// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CompositeImageAsset",
  platforms: [
    .iOS(.v15),
    .macOS(.v11)
  ],
  products: [
    .library(
      name: "CompositeImageAsset",
      targets: ["CompositeImageAsset"]),
  ],
  dependencies: [
    .package(path: "../CompositeAsset"),
  ],
  targets: [
    .target(
      name: "CompositeImageAsset",
      dependencies: [
        .product(name: "CompositeAsset", package: "CompositeAsset"),
      ]),
    // This package defines protocol only, and not implementations, so there are no tests.
  ]
)
