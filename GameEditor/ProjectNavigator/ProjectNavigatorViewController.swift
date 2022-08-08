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

    // Allow drag & drop of multiple items at once only if they all share the same source parent
    // (otherwise, the drop becomes super problematic)
    guard nodes.allShareSameParent else {
      return NSDragOperation()
    }

    // The only drag and drop operations we allow are local reorder (not e.g. objects from outside).
    //guard draggingIsLocalReorder(info: info) else {
    //  return NSDragOperation()
    //}

    // Check if we are dropping the mode into one of its descendants (not allowed)
    for draggedNode in draggedNodes! {
      if targetNode.isDescendant(of: draggedNode) {
        return NSDragOperation()
      }
    }

    info.animatesToDestination = true
    return .generic
  }

  func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
    // Nil represents the root.
    let targetNode = item as? Node ?? projectTree

    let indices = draggedNodes!.compactMap { $0.parent!.children.firstIndex(of: $0) }
    let parent = draggedNodes?.first?.parent

    if targetNode == parent {
      // Moving all nodes within the same parent



    } else {
      // Moving all nodes to  a separate parent

      draggedNodes!.forEach { $0.removeFromParent() }
      draggedNodes!.reversed().forEach {
        try? targetNode.insertChild($0, at: index)
      }

      let dstIndex = index == NSOutlineViewDropOnItemIndex ? 0 : index
      outlineView.beginUpdates()
      indices.forEach { itemIndex in
        outlineView.moveItem(at: itemIndex, inParent: parent, to: index, inParent: targetNode)
      }
      outlineView.endUpdates()
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
