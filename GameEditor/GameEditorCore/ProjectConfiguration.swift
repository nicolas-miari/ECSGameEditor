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

  /**
   Tree structure describing the grouping of all the project's game scenes and library assets.

   The scenes and assets are exported as two flat arrays, but during editing, they can be freely
   grouped for convenience or meaningfulness (for example, group all the separate scenes that make
   up a "stage" in the game, or group all the texture atlases that are exclusinve to a certain
   scene or stage).

   This free grouping is inspired by how source files and resources such as storyboard can be
   oganized into folders in an Xcode project.
   */
  var projectTree: Node = .debugProjectTree() //.emptyProjectTree()

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

  static func debugProjectTree() -> Node {
    return Node(name: "Root", children: [
      Node(name: "Folder 1", children: [
        Node(name: "File 1-1", payload: ""),
        Node(name: "File 1-2", payload: ""),
        Node(name: "Folder 1-1", children: [
        ]),
        Node(name: "File 1-3", payload: ""),
      ]),
      Node(name: "Folder 2", children: [
        Node(name: "File 2-1", payload: ""),
        Node(name: "File 2-2", payload: ""),
      ]),
      Node(name: "Folder 3", children: [
        Node(name: "File 3-1", payload: ""),
        Node(name: "File 3-2", payload: ""),
        Node(name: "File 3-3", payload: ""),
        Node(name: "File 4-4", payload: ""),
      ]),
    ])
  }
}
