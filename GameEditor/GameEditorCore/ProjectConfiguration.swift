//
//  ProjectConfiguration.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Foundation
import CodableTree

/**
 The project configuration contains all the state needed to edit a game but discarded when
 exporting, such as the custom folder grouping of scenes and assets.
 */
struct ProjectConfiguration: Codable {

  var projectTree: Node = .emptyProjectTree()

  // Creates a configuration object for a new (empty) project.
  public init() {
    
  }

  func fileWrapper() throws -> FileWrapper {
    let data = try JSONEncoder().encode(self)
    return FileWrapper(regularFileWithContents: data)
  }
}

extension Node {
  static func emptyProjectTree() -> Node {
    return Node(name: "Game", children: [
      Node(name: "Scenes", children: [
        Node(name: "Scene 1", payload: ""),
        Node(name: "Scene 2", payload: ""),
        Node(name: "Scene 3", payload: ""),
      ]),
      Node(name: "Assets", children: []),
    ])
  }
}
