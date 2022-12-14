// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ImageAssetImporter",
  platforms: [
    .macOS(.v11)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "ImageAssetImporter",
      targets: ["ImageAssetImporter"]),
  ],
  dependencies: [
    .package(path: "../AssetLibrary"),
    .package(path: "../BinaryResourceProvider"),
    .package(path: "../ImageAsset"),
    .package(path: "../SpriteSheetAsset"),
    .package(path: "../UniqueIdentifierProvider"),
  ],
  targets: [
    .target(
      name: "ImageAssetImporter",
      dependencies: [
        .product(name: "AssetLibrary", package: "AssetLibrary"),
        .product(name: "BinaryResourceProvider", package: "BinaryResourceProvider"),
        .product(name: "ImageAsset", package: "ImageAsset"),
        .product(name: "SpriteSheetAsset", package: "SpriteSheetAsset"),
        .product(name: "UniqueIdentifierProvider", package: "UniqueIdentifierProvider"),
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "ImageAssetImporterTests",
      dependencies: ["ImageAssetImporter"]),
  ]
)
