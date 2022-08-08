//
//  ProjectNavigatorViewController.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Cocoa
import CodableTree

/**
 How to set pane width: https://stackoverflow.com/a/41317631/433373
 */
class ProjectNavigatorViewController: DocumentViewController {

  @IBOutlet private weak var outlineView: NSOutlineView!

  lazy var projectTree: Node = Node(name: "Empty Project")

  private let pasteboardType = NSPasteboard.PasteboardType("com.nicolasmiari.gameproj.node")

  private var draggedNodes: [Node]?

  override func viewDidLoad() {
    super.viewDidLoad()

    outlineView.registerForDraggedTypes([pasteboardType])
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    if let document = document {
      projectTree = document.projectConfiguration.projectTree
      outlineView.reloadData()
    }
  }
}

// MARK: - NSOutlineView Delegate

extension ProjectNavigatorViewController: NSOutlineViewDelegate {

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    guard let node = item as? Node else {
      fatalError("")
    }

    let view: NSTableCellView? = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("NameCell"), owner: self) as? NSTableCellView

    if let textField = view?.textField {
      textField.stringValue = node.name
      textField.sizeToFit()
    }
    return view
  }
}

// MARK: - NSOutlineView Data Source

extension ProjectNavigatorViewController: NSOutlineViewDataSource {

  // MARK: - Read

  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let node = item as? Node else {
      return projectTree.children.count
    }
    return node.children.count
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let node = item as? Node else {
      return projectTree.children[index]
    }
    return node.children[index]
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    guard let node = item as? Node else {
      fatalError("")
    }
    return node.isBranch
  }

  // MARK: - Edit

  func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
    //guard let node = item as? Node, let name = object as? String else {
    //  fatalError("")
    //}
  }

  // MARK: - Reorder

  func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
    if let node = item as? Node {
      print("pasteboardWriterForItem: \(node.name)")
    }
    let pasteboardItem = NSPasteboardItem()
    pasteboardItem.setData(Data(), forType: pasteboardType)
    return pasteboardItem
  }

  func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
    self.draggedNodes = draggedItems as? [Node]
    if let nodes = draggedNodes {
      let names = nodes.map { $0.name }.joined(separator: ", ")
      print("dragging session will begin for: \(names)")
    }
    session.draggingPasteboard.setData(Data(), forType: pasteboardType)
  }

  func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
    self.draggedNodes = nil
  }

  func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
    guard let nodes = draggedNodes else {
      return NSDragOperation() // (this should not happen)
    }
    // Nil represents the root.
    let targetNode = item as? Node ?? projectTree

    // Can only drop on folders, never on files. And not on self!
    guard targetNode.notIn(nodes), targetNode.isBranch else {
      return NSDragOperation()
    }

    // TODO: Investigate why we need this
    guard index != NSOutlineViewDropOnItemIndex else {
      return NSDragOperation()
    }

    // The only drag and drop operations we allow are local reorder (not e.g. objects from outside).
    guard draggingIsLocalReorder(info: info) else {
      return NSDragOperation()
    }

    // Check if we are dropping the mode into one of its descendants (not allowed)
    for draggedNode in draggedNodes! {
      if targetNode.isDescendant(of: draggedNode) {
        return NSDragOperation()
      }
    }

    info.animatesToDestination = true
    return .move
  }

  func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
    let targetNode = item as? Node ?? projectTree // Nil represents the root node.

    // Group all dragged nodes by their current parent, so they can be processed one parent at a
    // time, removed from back to front (to avoid indices shifting midway).
    let grouped = draggedNodes!.grouped{ $0.parent }

    // [1] Update the outline view:
    outlineView.beginUpdates()
    grouped.forEach { group in
      guard let parent = group.first?.parent else {
        return // Should not happen (groups are never empty and dragged nodes always have a parent)
      }
      // Map nodes to their indices in the current parent:
      let childIndices: [Int] = group.compactMap { parent.children.firstIndex(of: $0) }.sorted()
      childIndices.reversed().forEach { childIndex in
        outlineView.moveItem(at: childIndex, inParent: parent, to: index, inParent: targetNode)
      }
    }
    outlineView.endUpdates()

    // [2] Update the data model:
    try? grouped.forEach { group in
      guard let parent = group.first?.parent else {
        return // Should not happen (groups are never empty and dragged nodes always have a parent)
      }
      // Map nodes to their indices in the current parent:
      let childIndices: [Int] = group.compactMap { parent.children.firstIndex(of: $0) }.sorted()

      // Remove nodes from current parent, back to front (to avoid index shifting), and insert into
      // new parent.
      // TODO: Group as onecomplex, undoable operation, and delgate to model controller (Document).
      try childIndices.reversed().forEach { childIndex in
        let child = try parent.removeChild(at: childIndex)
        try targetNode.insertChild(child, at: index)
      }
    }

    return true
  }

  private func draggingIsLocalReorder(info: NSDraggingInfo) -> Bool {
    guard info.draggingSource as? NSOutlineView == outlineView else {
      return false
    }
    guard draggedNodes != nil else {
      return false
    }
    guard info.draggingPasteboard.availableType(from: [pasteboardType]) != nil else {
      return false
    }
    return true
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
  var allShareSameParent: Bool {
    for node in self {
      if node.parent != first?.parent { return false }
    }
    return true
  }
}

extension Equatable {
  func notIn(_ array: [Self]) -> Bool {
    return !array.contains(self)
  }
}

extension Sequence {
  // Thanks https://stackoverflow.com/a/57503373/433373
  func grouped<T: Equatable>(by block: (Element) throws -> T) rethrows -> [[Element]] {
    return try reduce(into: []) { result, element in
      if let lastElement = result.last?.last, try block(lastElement) == block(element) {
        result[result.index(before: result.endIndex)].append(element)
      } else {
        result.append([element])
      }
    }
  }
}
