//
//  Document+Editing.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Foundation
import CodableTree

extension Document {

  public struct MenuItemDescriptor {
    /** Constants enumerating the possible values of `itemType`.*/
    public enum ItemType {
      /** The menu item is actionable, and should be identified using the associated tag.*/
      case action(_ tag: MenuItemTag)

      /**
       The menu item is a submenu; choosing it triggers no action but instead displays the items in
       the associated array.
       */
      case submenu(_ children: [MenuItemDescriptor])

      case separator
    }

    /** The string displayed for the menu item. */
    public let title: String

    /** The kind of menu item represented. */
    public let itemType: ItemType
  }

  public enum MenuItemTag: Int {

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

  public func menuItemDescriptors(for items: [DocumentOutlineItem]) -> [MenuItemDescriptor] {
    var descriptors: [MenuItemDescriptor] = []

    // Always include the delete item.
    if items.count == 1 {
      let title = items[0].title
      descriptors.append(MenuItemDescriptor(title: "Delete \"\(title)\"", itemType: .action(.deleteSelectedItems)))
    } else {
      descriptors.append(MenuItemDescriptor(title: "Delete items", itemType: .action(.deleteSelectedItems)))
    }

    // If single selection, include the New... submenu.
    if items.count == 1 {
      descriptors.append(MenuItemDescriptor(title: "", itemType: .separator))
      let addScene = MenuItemDescriptor(title: "Scene", itemType: .action(.addNewScene))
      let addAsset = MenuItemDescriptor(title: "Asset...", itemType: .action(.addNewAssetFromResourceFile))
      let addMenu = MenuItemDescriptor(title: "Add", itemType: .submenu([addScene, addAsset]))
      descriptors.append(addMenu)
    }

    // If all items are siblings, include Group...
    //if let nodes = items.map { $0.content } as? [Node], nodes.sameParent {
    //  let group = MenuItemDescriptor(title: "New Group from Selection", itemType: .action(.groupSelectedItems))
    //  descriptors.append(group)
    //}

    // If all items are unrelated folders, include the Dissolve groups option.

    return descriptors
  }

  public typealias ContextMenuCompletionHandler =
    (_ addedItems: [DocumentOutlineItem], _ removedItems: [DocumentOutlineItem]) -> Void

  public func projectOutlineMenuSelectedItem(
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

/*
struct NodeMoveOperation {
  let srcIndex: Int
  let srcParent: Node
  let dstIndex: Int
  let dstParent: Node

  func reversed() -> NodeMoveOperation {
    return NodeMoveOperation(srcIndex: dstIndex, srcParent: dstParent, dstIndex: srcIndex, dstParent: srcParent)
  }
}*/
