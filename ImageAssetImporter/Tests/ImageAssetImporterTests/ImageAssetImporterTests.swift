import XCTest

import AppKit
import AssetLibrary
import BinaryResourceProvider
import ImageFileImporter
import UniqueIdentifierProvider
import SpriteSheetAsset

@testable import ImageAssetImporter

final class ImageAssetImporterTests: XCTestCase {

  func testEmpty() async throws {
    // GIVEN:
    let fileImporter = ImageFileImporterFakeFactory.newFileImporterFake()
    fileImporter.stubUserSelectedImages([])

    let resourceProvider = BinaryResourceProviderFactory.newResourceProvider()
    let identifierProvider = UniqueIdentifierProviderFactory.newIdentifierProvider()
    let library = AssetLibraryFactory.newLibrary()

    let assetImporter = ImageAssetImporter(
      imageFileImporter: fileImporter,
      resourceProvider: resourceProvider,
      identifierProvider: identifierProvider,
      assetLibrary: library)

    // WHEN:
    try await assetImporter.start(in: NSViewController(), type: SpriteSheetAsset.self)

    // THEN:
    let atlases = library.assets(ofType: SpriteSheetAsset.self)
    XCTAssertEqual(atlases.count, 0)
  }
}
