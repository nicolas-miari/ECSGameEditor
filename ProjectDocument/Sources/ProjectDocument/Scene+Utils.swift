//
//  Scene.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Foundation
import Component
import Scene

extension Scene {

  // MARK: - Serialization

  func directoryWrapper() throws -> FileWrapper {
    let contentData = try JSONEncoder().encode(self)
    let contentFile = FileWrapper(regularFileWithContents: contentData)

    return FileWrapper(directoryWithFileWrappers: [
      .contentsFileName: contentFile
    ])
  }
}

// MARK: - Filewrapper Keys

extension String {
  fileprivate static let manifestFileName = "sceneManifest.json"
  fileprivate static let contentsFileName = "sceneContents.json"
}
