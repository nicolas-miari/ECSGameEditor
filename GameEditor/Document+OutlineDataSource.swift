//
//  Document+OutlineDataSource.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/10.
//

import AppKit
import CodableTree
import Asset

// MARK: - Project Outline Data Source

extension Document: NSOutlineViewDataSource {

  // MARK: - Support

  /**
   Casts the unsafe Any/Any? arguments of the NSOutlineViewDataSource API to the concrete type
   `DocumentOutlineItem` provided by the model controller, for convenience.
   */
  func outlineItem(for item: Any?) -> DocumentOutlineItem {
    guard let outlineItem = item as? DocumentOutlineItem else {
      return documentOutlineRootItem
    }
    return outlineItem
  }

  // MARK: - Data Source (Contents)

  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    let contents = outlineItem(for: item).contents
    switch contents {
    case let node as Node:
      return node.children.count
    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported outline view item content type: \(String(describing: type(of: contents)))")
    }
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    let contents = outlineItem(for: item).contents
    switch contents {
    case let node as Node:
      return outlineItem(for: node.children[index])
    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported outline view item content type: \(String(describing: type(of: contents)))")
    }
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    let numberOfChildren = self.outlineView(outlineView, numberOfChildrenOfItem: item)
    return numberOfChildren > 0
  }

  // MARK: - Data Source (Rename)

  func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
    // TODO: Implement.
  }

  // MARK: - Drag to Reorder

  var pasteboardType: NSPasteboard.PasteboardType {
    return NSPasteboard.PasteboardType("com.nicolasmiari.gameproj.node")
  }

  private func draggingIsLocalReorder(in outlineView: NSOutlineView, info: NSDraggingInfo) -> Bool {
    guard info.draggingSource as? NSOutlineView == outlineView else {
      return false
    }
    guard projectOutlineDraggedItem != nil else {
      return false
    }
    guard info.draggingPasteboard.availableType(from: [pasteboardType]) != nil else {
      return false
    }
    return true
  }

  func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
    let pasteboardItem = NSPasteboardItem()
    pasteboardItem.setData(Data(), forType: pasteboardType)
    return pasteboardItem
  }

  func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
    // Disable dragging of multiple items: the handling is too complex and error prone. For now, let
    // the user work around the limitation by groupping multiple items into a folder and dragging
    // that instead to save time.
    guard let draggedItem = draggedItems.first as? DocumentOutlineItem else {
      fatalError("")
    }
    self.projectOutlineDraggedItem = draggedItem

    session.draggingPasteboard.setData(Data(), forType: pasteboardType)
  }

  func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
    self.projectOutlineDraggedItem = nil
  }

  func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
    //Swift.print("Validate drop at index: \(index)")

    guard let draggedItem = projectOutlineDraggedItem else {
      return NSDragOperation() // (empty selection cannot be dragged)
    }
    let targetItem = outlineItem(for: item)

    guard canMove(draggedItem, to: targetItem) else {
      return NSDragOperation() // Model controller disallows operation.
    }

    // TODO: Investigate why we need this
    guard index != NSOutlineViewDropOnItemIndex else {
      return NSDragOperation()
    }

    // The only drag and drop operations we allow are local reorder (not e.g. objects from outside).
    guard draggingIsLocalReorder(in: outlineView, info: info) else {
      return NSDragOperation()
    }

    info.animatesToDestination = true
    return .move
  }

  func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
    guard let draggedItem = projectOutlineDraggedItem else {
      return false // (empty selection cannot be dragged)
    }
    let targetItem = outlineItem(for: item)

    guard let parent = self.parent(of: draggedItem), let currentIndex = indexInParent(of: draggedItem) else {
      fatalError("Dragged item has no parent!")
    }

    // Begin with the requested drop index
    var dropIndex = index

    // If moving within the same parent and to a higher index, adjust:
    if (parent == targetItem && currentIndex < dropIndex ) {
      dropIndex -= 1
    }

    // [1] Update the outline view:
    outlineView.beginUpdates()
    outlineView.moveItem(at: currentIndex, inParent: parent, to: dropIndex, inParent: targetItem)
    outlineView.endUpdates()

    // [2] Update the data model
    switch (draggedItem.contents, targetItem.contents) {
    case (let draggedNode as Node, let targetNode as Node):
      do {
        try targetNode.insertChild(draggedNode, at: dropIndex)
      } catch {
        fatalError(error.localizedDescription)
      }
    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported outline view item content type.")
    }
    return true
  }

  
}

/**
 The document exposes a tree of Nodes via this interface, for the UI layer to present.

 The UI is only concerned with the tree structure (display) and which reordering operations are
 allowed to the user (input handling), but is otherwise unaware of what each tree node represents.
 */
extension Document {

  func setupDocumentOutlineRootItem(node: Node) {
    self.documentOutlineRootItem = DocumentOutlineItem(contents: node)
  }

  /**
   Instances of `DocumentOutlineItem` must be unique for each represented document item. By
   centralizing access in this method, we can enforce lazy instantiation and subsequent caching.
   */
  private func outlineItem(for item: any DocumentItem) -> DocumentOutlineItem {
    if let cached = outlineItemCache[ObjectIdentifier(item)] {
      return cached
    }
    let new = DocumentOutlineItem(contents: item)
    outlineItemCache[ObjectIdentifier(item)] = new
    return new
  }

  func numberOfChildren(in item: DocumentOutlineItem) -> Int {
    /**
     If the item is a folder node, imply return its child count.
     If the item is a leaf node representing a scene, return its entity count.
     If the item is a library asset, return 0.
     */
    switch item.contents {
    case let node as Node:
      return node.children.count
    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported type \(String(describing: type(of: item.contents)))")
    }
  }

  func childItem(at index: Int, of item: DocumentOutlineItem) -> DocumentOutlineItem {
    switch item.contents {
    case let node as Node:
      return outlineItem(for: node.children[index])
    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported type \(String(describing: type(of: item.contents)))")
    }
  }

  func indexInParent(of item: DocumentOutlineItem) -> Int? {
    switch item.contents {
    case let node as Node:
      return node.indexInParent
    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported type \(String(describing: type(of: item.contents)))")
    }
  }

  func parent(of item: DocumentOutlineItem) -> DocumentOutlineItem? {
    switch item.contents {
    case let node as Node:
      guard let parent = node.parent else {
        return nil
      }
      return outlineItem(for: parent)
    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported type \(String(describing: type(of: item.contents)))")
    }
  }

  func canMove(_ item: DocumentOutlineItem, to tentativeParent: DocumentOutlineItem) -> Bool {
    switch (item.contents, tentativeParent.contents) {
    case (let itemNode as Node, let parentNode as Node):
      guard parentNode != itemNode else {
        Swift.print("Cannot drop node \(itemNode.name) as child of \(parentNode.name)")
        return false
      }
      guard parentNode.isBranch else {
        return false
      }
      return !parentNode.isDescendant(of: itemNode)
    default:
      fatalError("Unsupported item contents.")
    }
  }

  /**
   Returns and array of the menu options that should be shown for the specified items.
   */
  func contextMenuItems(for items: [DocumentOutlineItem]) -> [NSMenuItem] {
    // If all itmes have the same parent, provide an option to group them into a new folder.

    // If there is a single folder item, provide the option to "dissolve it" and expand its contents
    // in place.

    // Regardless of the selection, provide an option to delete the affected items.

    // Regardless of the selection, provide an option to create a new item (after prompt).

    return []
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

/*
struct DocumentOutlineMenuAction {
  let title: String
  let block: ([DocumentOutlineItem]) -> Void
}*/

// MARK: -

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

extension Node {
  fileprivate func isDescendant(of otherNode: Node) -> Bool {
    guard let parent = parent else {
      return false
    }
    if parent == otherNode {
      return true
    }
    return parent.isDescendant(of: otherNode)
  }
}


extension Array where Element: Node {
  /// Returns true if all elements have the same node as their parent.
  var sameParent: Bool {
    for node in self {
      if node.parent != first?.parent { return false }
    }
    return true
  }
}
