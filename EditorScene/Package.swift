// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "EditorScene",
  platforms: [
    .macOS(.v11)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "EditorScene",
      targets: ["EditorScene"]),
  ],
  dependencies: [
    .package(url: "https://github.com/nicolas-miari/CodableTree.git", from: "1.0.0"),
    .package(url: "https://github.com/nicolas-miari/Component.git", from: "1.0.0"),
    .package(url: "https://github.com/nicolas-miari/Entity.git", from: "1.0.0"),
    .package(url: "https://github.com/nicolas-miari/Transform.git", from: "1.0.0"),

  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "EditorScene",
      dependencies: [
        .product(name: "CodableTree", package: "CodableTree"),
        .product(name: "Component", package: "Component"),
        .product(name: "Entity", package: "Entity"),
        .product(name: "Transform", package: "Transform"),
      ]),
    .testTarget(
      name: "EditorSceneTests",
      dependencies: ["EditorScene"]),
  ]
)
