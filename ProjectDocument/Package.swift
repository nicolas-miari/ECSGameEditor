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
      .package(path: "../ImageAssetImporter.git"),
      .package(path: "../ImageFileImporter.git"),
      .package(path: "../AssetLibrary"),
      .package(path: "../BinaryResourceProvider"),
      .package(path: "../ImageAsset"),
      .package(path: "../UniqueIdentifierProvider"),
      .package(url: "https://github.com/nicolas-miari/Scene.git", from: "1.0.0")
    ],
    targets: [
      .target(
        name: "ProjectDocument",
          dependencies: [
            .product(name: "AssetLibrary", package: "AssetLibrary"),
            .product(name: "BinaryResourceProvider", package: "BinaryResourceProvider"),
            .product(name: "ImageAsset", package: "ImageAsset"),
            .product(name: "ImageAssetImporter", package: "ImageAssetImporter"),
            .product(name: "ImageFileImporter", package: "ImageFileImporter"),
            .product(name: "Scene", package: "Scene"),
            .product(name: "UniqueIdentifierProvider", package: "UniqueIdentifierProvider"),
          ]),
      .testTarget(
        name: "ProjectDocumentTests",
        dependencies: ["ProjectDocument"]),
    ]
)
