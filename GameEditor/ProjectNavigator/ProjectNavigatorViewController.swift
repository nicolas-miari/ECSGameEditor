//
//  ProjectNavigatorViewController.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import AppKit

/**
 How to set pane width: https://stackoverflow.com/a/41317631/433373
 */
class ProjectNavigatorViewController: DocumentViewController {

  @IBOutlet private weak var outlineView: NSOutlineView!

  private let pasteboardType = NSPasteboard.PasteboardType("com.nicolasmiari.gameproj.node")

  private var draggetOutlineItems: [DocumentOutlineItem]?

  private let contextMenu = NSMenu(title: "Context")

  override func viewDidLoad() {
    super.viewDidLoad()

    outlineView.registerForDraggedTypes([pasteboardType])
    contextMenu.delegate = self
    outlineView.menu = contextMenu
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    if document != nil {
      outlineView.reloadData()
    }
  }
}

// MARK: - NSMenu Delegate

extension ProjectNavigatorViewController: NSMenuDelegate {
  // Thanks https://stackoverflow.com/a/65105980/433373
  func menuNeedsUpdate(_ menu: NSMenu) {
    /*
    let indices = outlineView.contextMenuIndices
    menu.removeAllItems()

    let items = indices.map { outlineView.item(atRow: $0) as! Node }

    // Group into new folder
    if indices == outlineView.selectedRowIndexes {
      let items = indices.map { outlineView.item(atRow: $0) as! Node }
      if items.sameParent {
        menu.addItem(withTitle: "New folder from selection", action: #selector(groupSelectedItems(_:)), keyEquivalent: "")
      }
    }*/
  }

  @objc func groupSelectedItems(_ sender: Any) {
    /*
    let items = outlineView.selectedRowIndexes.map { outlineView.item(atRow: $0) as! Node }
    guard items.sameParent else {
      fatalError("Invalid Operation")
    }
    let childIndices = items.map { $0.parent!.children.firstIndex(of: $0) }
     */
  }
}

extension NSOutlineView {
  // Thanks https://stackoverflow.com/a/65105980/433373
  var contextMenuIndices: IndexSet {
    /*
     If we click on a selection, all selecte dindices. If we click outside of a selection, only
     the index clicked on.
     */
    var indices = selectedRowIndexes
    if clickedRow >= 0 && (selectedRowIndexes.isEmpty || !selectedRowIndexes.contains(clickedRow)) {
      indices = [clickedRow]
    }
    return indices
  }
}

// MARK: - NSOutlineView Delegate

extension ProjectNavigatorViewController: NSOutlineViewDelegate {

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    guard let outlineItem = item as? DocumentOutlineItem else {
      let typeName = String.init(describing: type(of: item))
      fatalError("Incompatible Outline Item Type: \(typeName) does not conform to DocumentOutlineItem.")
    }

    let view: NSTableCellView? = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("NameCell"), owner: self) as? NSTableCellView

    if let textField = view?.textField {
      textField.stringValue = outlineItem.title
      textField.sizeToFit()
    }
    if let imageView = view?.imageView {
      imageView.image = NSImage(named: NSImage.Name(outlineItem.imageName))
    }
    return view
  }
}

// MARK: - NSOutlineView Data Source

extension ProjectNavigatorViewController: NSOutlineViewDataSource {

  // MARK: - Support

  func outlineItem(for item: Any?) -> DocumentOutlineItem {
    guard let outlineItem = item as? DocumentOutlineItem else {
      return document!.documentOutlineRootItem
    }
    return outlineItem
  }

  // MARK: - Read

  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let document = document else {
      return 0
    }
    return document.numberOfChildren(in: outlineItem(for: item))
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let document = document else { return 0 }
    return document.childItem(at: index, of: outlineItem(for: item))
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    guard let document = document else { return false }

    return document.numberOfChildren(in: outlineItem(for: item)) > 0
  }

  // MARK: - Edit

  func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
    // TODO: Implement.
  }

  // MARK: - Reorder

  func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
    let pasteboardItem = NSPasteboardItem()
    pasteboardItem.setData(Data(), forType: pasteboardType)
    return pasteboardItem
  }

  func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
    guard let items = draggedItems as? [DocumentOutlineItem] else {
      fatalError("")
    }
    let names = items.map { $0.title }.joined(separator: ", ")
    Swift.print("dragging session will begin for: \(names)")

    self.draggetOutlineItems = items
    session.draggingPasteboard.setData(Data(), forType: pasteboardType)
  }

  func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
    self.draggetOutlineItems = nil
  }

  func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
    guard let document = document else { return NSDragOperation() }

    guard let items = draggetOutlineItems else {
      return NSDragOperation() // (this should not happen)
    }
    let targetItem = outlineItem(for: item)

    guard document.canMove(items, to: targetItem) else {
      return NSDragOperation()
    }

    guard targetItem.notIn(items) else {
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

    info.animatesToDestination = true
    return .move
  }

  func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
    guard let document = document else { return false }

    guard let items = draggetOutlineItems else {
      fatalError("")
    }
    let targetItem = outlineItem(for: item)
    let groupedItems = document.groupItemsByParent(items, sortSiblings: .orderedDescending)

    // [1] Update the outline view:
    outlineView.beginUpdates()
    groupedItems.forEach { group in
      guard let parent = document.parent(of: group[0]) else {
        return // Should not happen (groups are never empty and dragged nodes always have a parent)
      }
      let childIndices = group.compactMap { document.indexInParent(of: $0) }

      childIndices.forEach { childIndex in
        outlineView.moveItem(at: childIndex, inParent: parent, to: index, inParent: targetItem)
      }
    }
    outlineView.endUpdates()

    // [2] Update the data model:
    document.moveItems(items, toIndex: index, of: targetItem)

    /*
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
    }*/

    return true
  }

  private func draggingIsLocalReorder(info: NSDraggingInfo) -> Bool {
    guard info.draggingSource as? NSOutlineView == outlineView else {
      return false
    }
    guard draggetOutlineItems != nil else {
      return false
    }
    guard info.draggingPasteboard.availableType(from: [pasteboardType]) != nil else {
      return false
    }
    return true
  }
}



extension Equatable {
  func notIn(_ array: [Self]) -> Bool {
    return !array.contains(self)
  }
}


