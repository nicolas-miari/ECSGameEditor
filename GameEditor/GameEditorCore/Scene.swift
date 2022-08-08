//
//  Scene.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Foundation
import Component

/**
 Represents one scene within a game editor project.

 A scene in the editor consists of a list of entities, each with one or more components attached.
 */
class Scene: Codable, Identifiable {

  typealias ID = UUID

  private var entities: [UUID: ComponentList] = [:]

  let id: ID

  init() {
    self.id = UUID()
  }

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
