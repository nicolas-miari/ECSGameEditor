// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProjectDocument",
    platforms: [
      .macOS(.v11)
    ],
    products: [
      // Products define the executables and libraries a package produces, and make them visible to other packages.
      .library(
        name: "ProjectDocument",
        targets: ["ProjectDocument"]),
    ],
    dependencies: [
      .package(url: "https://github.com/nicolas-miari/AssetLibrary.git", from: "1.0.0"),
      .package(url: "https://github.com/nicolas-miari/BinaryResourceProvider.git", from: "0.0.0"),
      .package(url: "https://github.com/nicolas-miari/ImageAsset.git", from: "1.0.2"),
      .package(url: "https://github.com/nicolas-miari/Scene.git", from: "1.0.0"),
      .package(url: "https://github.com/nicolas-miari/UniqueIdentifierProvider.git", from: "0.0.1"),
    ],
    targets: [
      .target(
        name: "ProjectDocument",
          dependencies: [
            .product(name: "AssetLibrary", package: "AssetLibrary"),
            .product(name: "BinaryResourceProvider", package: "BinaryResourceProvider"),
            .product(name: "ImageAsset", package: "ImageAsset"),
            .product(name: "Scene", package: "Scene"),
            .product(name: "UniqueIdentifierProvider", package: "UniqueIdentifierProvider"),
          ]),
      .testTarget(
        name: "ProjectDocumentTests",
        dependencies: ["ProjectDocument"]),
    ]
)
