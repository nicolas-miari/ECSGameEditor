import AppKit
import CompositeImageAsset
import AssetLibrary
import BinaryResourceProvider
import ImageAsset
import UniqueIdentifierProvider
import ImageFileImporter
import TextureAtlasAsset

extension TextureAtlasAsset {
  
}

public struct ImageAssetImporter {

  let imageFileImporter: any ImageFileImporter
  let assetLibrary: any AssetLibrary
  let binaryResourcePrivider: any BinaryResourceProvider
  let identifierProvider: any UniqueIdentifierProvider

  public init(
    imageFileImporter: any ImageFileImporter,
    resourceProvider: any BinaryResourceProvider,
    identifierProvider: any UniqueIdentifierProvider,
    assetLibrary: any AssetLibrary
  ) {
    self.imageFileImporter = imageFileImporter
    self.assetLibrary = assetLibrary
    self.binaryResourcePrivider = resourceProvider
    self.identifierProvider = identifierProvider
  }

  /// Kick off the asset import flow by launching an open file panel for the user to choose the
  /// input file(s).
  ///
  @MainActor
  public func start<T: CompositeImageAsset>(in host: NSViewController, type: T.Type) async throws {

    // Open one or more image files using the file system APIs.
    let urls = await imageFileImporter.openUserSelectedImages()

    // Have the user specify the asset options.
    guard let options: T.Options = await InputImageOptionsViewController.beginSheet(in: host, urls: urls) else {
      // User cancelled
      return
    }

    // Pass each URL to the binary resource provider to be cached, and match the resulting IDs with
    // the original images' names.
    let imageNamesAndIdentifiers: [(String, String)] = urls.compactMap {
      guard let identifier = self.binaryResourcePrivider.addImage(at: $0) else {
        return nil
      }
      let name = $0.deletingPathExtension().lastPathComponent
      return (name, identifier)
    }

    // Create a new image asset with each pair and add it to the library.
    let imageAssets = try imageNamesAndIdentifiers.map { (name, identifier) in
      let image = try ImageAsset(name: name, resourceIdentifier: identifier, identifierProvider: identifierProvider)
      return image
    }
    imageAssets.forEach { assetLibrary.addAsset($0) }
    let imageAssetIdentifiers = imageAssets.map { $0.identifier }

    // Create the composite asset with the images as dependencies
    let compositeAsset: T = try T.init(dependencies: imageAssetIdentifiers, identifierProvider: identifierProvider, options: options)
    assetLibrary.addAsset(compositeAsset)
  }
}

/*
struct AssetConfigurationOptions {
  let displayName: String
  let assumedScaleFactor: Float
}*/

extension CGImage {

  static func withContents(of url: URL) -> CGImage? {
    guard let imageDataProvider = CGDataProvider(url: url as CFURL) else {
      return nil
    }
    let image = CGImage(pngDataProviderSource: imageDataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    return image
  }
}

// TODO: Move to the BinaryResourceProvider module
extension BinaryResourceProvider {
  func addImage(at url: URL) -> String? {
    guard let image = CGImage.withContents(of: url) else {
      return nil
    }
    return add(image)
  }
}
