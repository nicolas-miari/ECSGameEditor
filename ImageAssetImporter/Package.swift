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
    .package(url: "https://github.com/nicolas-miari/AssetLibrary.git", from: "1.0.0"),
    .package(url: "https://github.com/nicolas-miari/BinaryResourceProvider.git", from: "1.0.0"),
    .package(url: "https://github.com/nicolas-miari/ImageAsset.git", from: "1.0.2"),
    .package(url: "https://github.com/nicolas-miari/TextureAtlasAsset.git", from: "2.0.1"),
    .package(url: "https://github.com/nicolas-miari/UniqueIdentifierProvider.git", from: "0.0.1"),
  ],
  targets: [
    .target(
      name: "ImageAssetImporter",
      dependencies: [
        .product(name: "AssetLibrary", package: "AssetLibrary"),
        .product(name: "BinaryResourceProvider", package: "BinaryResourceProvider"),
        .product(name: "ImageAsset", package: "ImageAsset"),
        .product(name: "TextureAtlasAsset", package: "TextureAtlasAsset"),
        .product(name: "UniqueIdentifierProvider", package: "UniqueIdentifierProvider"),
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "ImageAssetImporterTests",
      dependencies: ["ImageAssetImporter"]),
  ]
)
