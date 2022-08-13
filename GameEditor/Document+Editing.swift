//
//  Document+Editing.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Foundation
import CodableTree

extension Document {

  enum MenuItemTag: Int {

    /**
     Menu option to group the affected tems into a new folder. Available for any non-mepty
     selection of sibling items.
     */
    case groupSelectedItems = 1

    /**
     Menu option to ungroup the selected folders in-place (i.e., replacing the folders with their
     contents, at the same level). Available only for selections that contain one or more folders,
     none of which is an ancestor of the other.
     */
    case dissolveSelectedGroups = 2

    /**
     Menu option to delete the selcted item(s). Available for any non-mepty selection.
     */
    case deleteSelectedItems = 3

    /**
     Available for single-item selections only. If the selected item is a scene or asset, the new
     scene is created immediately after at the same level. If the selected item is a folder, it is
     inserted inside it, as the last child.
     */
    case addNewScene = 4

    /**
     Available for single-item selections only. The document will handle file import and initial
     asset configuration in a series of prompts, and finally communicate the insertion of the newly
     created item asynchronously.
     */
    case addNewAssetFromResourceFile = 5

  }

  typealias ContextMenuCompletionHandler =
    (_ addedItems: [DocumentOutlineItem], _ removedItems: [DocumentOutlineItem]) -> Void

  func projectOutlineMenuSelectedItem(
    tag: Int, items: [DocumentOutlineItem], completion: @escaping ContextMenuCompletionHandler) {
    guard let option = MenuItemTag(rawValue: tag) else {
      fatalError("Unsupported operation (tag: \(tag)")
    }
    switch option {
    case .groupSelectedItems:
      handleGroupItems(items, completion: completion)

    case .dissolveSelectedGroups:
      handleDissolveGroups(items, completion: completion)

    case .deleteSelectedItems:
      handleDeleteItems(items, completion: completion)

    case .addNewScene:
      handleNewScene(items, completion: completion)

    default:
      break
    }
  }

  fileprivate func handleGroupItems(
    _ items: [DocumentOutlineItem],
    completion: @escaping ContextMenuCompletionHandler) {

      

  }

  fileprivate func handleDissolveGroups(
    _ items: [DocumentOutlineItem],
    completion: @escaping ContextMenuCompletionHandler) {

  }

  fileprivate func handleDeleteItems(
    _ items: [DocumentOutlineItem],
    completion: @escaping ContextMenuCompletionHandler) {
  }

  fileprivate func handleNewScene(
    _ items: [DocumentOutlineItem],
    completion: @escaping ContextMenuCompletionHandler) {
  }
}

struct NodeMoveOperation {
  let srcIndex: Int
  let srcParent: Node
  let dstIndex: Int
  let dstParent: Node

  func reversed() -> NodeMoveOperation {
    return NodeMoveOperation(srcIndex: dstIndex, srcParent: dstParent, dstIndex: srcIndex, dstParent: srcParent)
  }
}
