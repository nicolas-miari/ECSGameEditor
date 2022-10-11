// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ImageFileImporter",
  platforms: [
    .macOS(.v11)
  ],
  products: [
    .library(
      name: "ImageFileImporter",
      targets: ["ImageFileImporter"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "ImageFileImporter",
      dependencies: []),
    // No test target is possible since the implementation uses the interactive NSOpenPanel.
  ]
)
