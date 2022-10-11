//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2022/10/09.
//

import AppKit
import ImageAssetImporter
import ImageFileImporter
import SpriteSheetAsset
import UniqueIdentifierProvider

extension Document {

  @IBAction public func beginTextureAtlasImport(_ sender: Any) {
    guard let viewController = windowControllers[0].contentViewController else {
      fatalError()
    }

    let fileImporter = ImageFileImporterFactory.newFileImporter()
    let assetImporter = ImageAssetImporter(
      imageFileImporter: fileImporter,
      resourceProvider: self.resourceProvider,
      identifierProvider: self.identifierProvider,
      assetLibrary: self.assetLibrary)

    Task {
      do {
        try await assetImporter.start(in: viewController, type: SpriteSheetAsset.self)
      } catch {
        let alert = NSAlert(error: error)
        _ = alert.runModal()
      }
    }
  }
}
