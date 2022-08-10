//
//  Document+OutlineDataSource.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/10.
//

import AppKit
import CodableTree
import Asset

/**
 The document exposes a tree of Nodes via this interface, for the UI layer to present.

 The UI is only concerned with the tree structure (display) and which reordering operations are
 allowed to the user (input handling), but is otherwise unaware of what each tree node represents.
 */
extension Document {

  var documentOutlineRootItem: DocumentOutlineItem {
    return DocumentOutlineItem(contents: projectConfiguration.projectTree)
  }

  func numberOfChilden(in item: DocumentOutlineItem) -> Int {
    /**
     If the item is a folder node, imply return its child count.
     If the item is a leaf node representing a scene, return its entity count.
     If the item is a library asset, return 0.
     */
    switch item.contents {
    case let node as Node:
      return node.children.count

    default:
      fatalError("Unsupported type \(String(describing: type(of: item.contents)))")
    }
  }

  func childItem(at index: Int, of item: DocumentOutlineItem) -> DocumentOutlineItem {
    if let node = item.contents as? Node {
      return DocumentOutlineItem(contents: node.children[index])
    }
    // TODO: Implement for sub-node objects (Scene entities, entity components).
    fatalError("Unsupported item type.")
  }

  func indexInParent(of item: DocumentOutlineItem) -> Int? {
    if let node = item.contents as? Node {
      return node.indexInParent
    }
    // TODO: Implement for sub-node objects (Scene entities, entity components).
    fatalError("Unsupported item type.")
  }

  func parent(of item: DocumentOutlineItem) -> DocumentOutlineItem? {
    switch item.contents {
    case let node as Node:
      guard let parent = node.parent else {
        return nil
      }
      return DocumentOutlineItem(contents: parent)

    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported type \(String(describing: type(of: item.contents)))")
    }
  }

  /**

   */
  func groupItemsByParent(_ items: [DocumentOutlineItem], sortSiblings sortOrder: ComparisonResult = .orderedDescending) -> [[DocumentOutlineItem]] {
    /**
     This method is called as a result of a multiple-item drag and drop operation. This is only
     allowed if all dragged items are of Node type (whether it's a folder, a scene, or an asset) so
     it is safe to unwrap the contents of each outline item as a Node.
     We cannot however map the DocumentOutlineItem instances themselves, because the outline view
     might use object identity to implement continuity during moves.
     */
    let grouped = items.grouped { self.parent(of: $0)! }

    return grouped.map { group in
      return group.sorted { lhs, rhs in
        guard let leftNode = lhs.contents as? Node, let rightNode = rhs.contents as? Node else {
          fatalError("Unsupported item contents.")
        }
        guard leftNode.parent == rightNode.parent else {
          fatalError("Nodes are not siblings.")
        }
        guard let leftIndex = leftNode.indexInParent, let rightIndex = rightNode.indexInParent else {
          fatalError("Cannot sort orphan node(s) by index in parent.")
        }
        return leftIndex < rightIndex
      }
    }
  }

  func canMove(_ items: [DocumentOutlineItem], to tentativeParent: DocumentOutlineItem) -> Bool {
    /**
     For nodes, check that we are not dropping an ancestor inside a descendant (would create a loop)
     */
    return true
  }

  func moveItems(_ items: [DocumentOutlineItem], toIndex index: Int, of item: DocumentOutlineItem) {
    /**
     This method is called as a result of a multiple-item drag and drop operation. This is only
     allowed if all dragged items are of Node type (whether it's a folder, a scene, or an asset) so
     it is safe to unwrap the contents of each outline item as a Node.
     */
    let contents = items.map { $0.contents }

    if let nodes = contents as? [Node], let target = item.contents as? Node {
      nodes.grouped { $0.parent }.forEach { group in
        let sorted = group.sorted {
          guard let lhs = $0.indexInParent, let rhs = $1.indexInParent else {
            fatalError("Cannot sort orphan node(s) by index in parent.")
          }
          return lhs > rhs
        }
        sorted.forEach {
          try? target.insertChild($0, at: index)
        }
      }
    } else {
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported type \(String(describing: type(of: contents)))")
    }
  }

  func contextMenuForSelectedItems(_ items: [DocumentOutlineItem]) -> NSMenu? {
    fatalError("Unimplemented")
  }

}

// MARK: - Supporting Types

/**
 A concrete class type wrapping the represented types, for the UI to handle.

 Equatable Conformance: Two instances compare as equal if they both wrap same opaque object.
*/
class DocumentOutlineItem: Equatable {

  // The title text to use when displaying the item.
  public var title: String {
    return contents.name
  }

  public var imageName: String {
    return "" // TODO: Implement
  }

  /// The wrapped object. It can be of any type that conforms to `DocumentItem`.
  fileprivate let contents: any DocumentItem

  fileprivate init(contents: any DocumentItem) {
    self.contents = contents
  }

  static func == (lhs: DocumentOutlineItem, rhs: DocumentOutlineItem) -> Bool {
    /**
     Both wrapped objects might be of different concrete types, but they're guaranteed to be
     reference types by the AnyObject constraint on DocumentItem; so compare the memory addresses:
     */
    return (lhs.contents as AnyObject) === (rhs.contents as AnyObject)
  }
}

/**
 A protocol for the represented types (Node, Scene) to conform to.

 Conforming types must be reference types so that variables of existential types can be compared
 using object identity.
 */
private protocol DocumentItem: AnyObject, Equatable {
  var name: String { get }
}

extension Node: DocumentItem {
}

fileprivate struct SiblingNodeComparator: SortComparator {

  var order: SortOrder

  typealias Compared = Node

  func compare(_ lhs: Node, _ rhs: Node) -> ComparisonResult {
    guard lhs.parent == rhs.parent else {
      fatalError("Nodes are not siblings")
    }
    let leftIndex = lhs.indexInParent ?? -1
    let rightIndex = rhs.indexInParent ?? -1
    switch order {
    case .forward:
      return leftIndex < rightIndex ? .orderedAscending : .orderedDescending
    case .reverse:
      return leftIndex > rightIndex ? .orderedAscending : .orderedDescending
    }
  }
}


