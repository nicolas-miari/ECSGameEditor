//
//  Document.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Cocoa
import AssetLibrary
import BinaryResourceProvider

class Document: NSDocument {

  var projectConfiguration: ProjectConfiguration
  var assetLibrary: AssetLibrary
  var resourceProvider: BinaryResourceProvider
  var scenes: [String: Scene]

  var documentOutlineRootItem: DocumentOutlineItem!

  var outlineItemCache: [ObjectIdentifier: DocumentOutlineItem] = [:]

  override init() {
    self.projectConfiguration = ProjectConfiguration()
    self.assetLibrary = AssetLibraryFactory.newLibrary()
    self.resourceProvider = BinaryResourceProviderFactory.newResourceProvider()
    self.scenes = [:]

    super.init()

    setupDocumentOutlineRootItem(node: projectConfiguration.projectTree)
  }

  override class var autosavesInPlace: Bool {
    return true
  }

  override func makeWindowControllers() {
    // Returns the Storyboard that contains your Document window.
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
    self.addWindowController(windowController)
  }

  override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
    let sceneDirectories = try scenes.mapValues {
      try $0.directoryWrapper()
    }
    let projectConfigurationFile = try projectConfiguration.fileWrapper()
    let sceneDirectory = FileWrapper(directoryWithFileWrappers: sceneDirectories)
    let assetLibraryDirectory = assetLibrary.directoryWrapper()
    let binaryResourceDirectory = resourceProvider.directoryWrapper()

    return FileWrapper(directoryWithFileWrappers: [
      .projectConfigurationFileName: projectConfigurationFile,
      .scenesDirectoryName: sceneDirectory,
      .assetLibraryDirectoryName: assetLibraryDirectory,
      .binaryResourceDirectoryName: binaryResourceDirectory,
    ])
  }

  override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
    // 1. Read all scenes, asset library items, and binary resources from wrapper.
    guard let scenesDirectory = fileWrapper.fileWrappers?[.scenesDirectoryName] else {
      throw DocumentError.corruptedPackage(detailedInfo: "")
    }
    self.scenes = try readScenes(from: scenesDirectory)

    guard let assetLibraryDirectory = fileWrapper.fileWrappers?[.assetLibraryDirectoryName] else {
      throw DocumentError.corruptedPackage(detailedInfo: "")
    }
    self.assetLibrary = try AssetLibraryFactory.loadAssetLibrary(from: assetLibraryDirectory)

    guard let binaryResourcesDirectory = fileWrapper.fileWrappers?[.binaryResourceDirectoryName] else {
      throw DocumentError.corruptedPackage(detailedInfo: "")
    }
    self.resourceProvider = try BinaryResourceProviderFactory.loadResourceProvider(from: binaryResourcesDirectory)

    // 2. Read project configuration
    guard let projectConfigurationFile = fileWrapper.fileWrappers?[.projectConfigurationFileName],
    let projectConfigurationData = projectConfigurationFile.regularFileContents else {
      throw DocumentError.corruptedPackage(detailedInfo: "")
    }
    self.projectConfiguration = try JSONDecoder().decode(ProjectConfiguration.self, from: projectConfigurationData)
  }

  override var isEntireFileLoaded: Bool {
    return true
  }

  private func readScenes(from directory: FileWrapper) throws -> [String: Scene] {
    guard let sceneDirectories = directory.fileWrappers else {
      throw DocumentError.corruptedPackage(detailedInfo: "")
    }
    return try sceneDirectories.mapValues{
      guard let data = $0.regularFileContents else {
        throw DocumentError.corruptedPackage(detailedInfo: "")
      }
      return try JSONDecoder().decode(Scene.self, from: data)
    }
  }
}


enum DocumentError: LocalizedError {
  case corruptedPackage(detailedInfo: String)
}
// MARK: - Supporting Extensions

extension String {
  fileprivate static let projectConfigurationFileName = "ProjectConfiguration.json"
  fileprivate static let scenesDirectoryName = "Scenes"
  fileprivate static let assetLibraryDirectoryName = "AssetLibrary"
  fileprivate static let binaryResourceDirectoryName = "BinaryResources"
}

