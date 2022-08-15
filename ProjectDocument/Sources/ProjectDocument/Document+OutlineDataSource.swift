//
//  Document+OutlineDataSource.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/10.
//

import AppKit
import CodableTree
import Asset
import EditorScene

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

  public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    let contents = outlineItem(for: item).contents
    switch contents {
    case let node as Node:
      return node.children.count

    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported outline view item content type: \(String(describing: type(of: contents)))")
    }
  }

  public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    let contents = outlineItem(for: item).contents
    switch contents {
    case let node as Node:
      return outlineItem(for: node.children[index])
    default:
      // TODO: Implement for sub-node objects (Scene entities, entity components).
      fatalError("Unsupported outline view item content type: \(String(describing: type(of: contents)))")
    }
  }

  public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    let numberOfChildren = self.outlineView(outlineView, numberOfChildrenOfItem: item)
    return numberOfChildren > 0
  }

  // MARK: - Data Source (Rename)

  public func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?,
    for tableColumn: NSTableColumn?, byItem item: Any?) {
    // TODO: Implement.
  }

  // MARK: - Drag to Reorder

  public var pasteboardType: NSPasteboard.PasteboardType {
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

  public func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any)
    -> NSPasteboardWriting? {

    let pasteboardItem = NSPasteboardItem()
    pasteboardItem.setData(Data(), forType: pasteboardType)
    return pasteboardItem
  }

  public func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession,
    willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {

    // Disable dragging of multiple items: the handling is too complex and error prone. For now, let
    // the user work around the limitation by groupping multiple items into a folder and dragging
    // that instead to save time.
    guard let draggedItem = draggedItems.first as? DocumentOutlineItem else {
      fatalError("")
    }
    self.projectOutlineDraggedItem = draggedItem

    session.draggingPasteboard.setData(Data(), forType: pasteboardType)
  }

  public func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession,
    endedAt screenPoint: NSPoint, operation: NSDragOperation) {

    self.projectOutlineDraggedItem = nil
  }

  public func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo,
    proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {

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

  public func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?,
    childIndex index: Int) -> Bool {

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
     If the item is a folder node, simply return its child count.
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
}

// MARK: - Supporting Types



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
