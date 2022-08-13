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

  // MARK: - NSViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    outlineView.registerForDraggedTypes([pasteboardType])
    outlineView.draggingDestinationFeedbackStyle = .sourceList
    outlineView.menu = contextMenu
    contextMenu.delegate = self
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    if let document = document {
      outlineView.dataSource = document
      outlineView.delegate = self
      outlineView.registerForDraggedTypes([document.pasteboardType])
      outlineView.reloadData()
    }
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

// MARK: - NSMenu Delegate

extension ProjectNavigatorViewController: NSMenuDelegate {
  // Thanks https://stackoverflow.com/a/65105980/433373
  func menuNeedsUpdate(_ menu: NSMenu) {
    let indices = outlineView.contextMenuIndices
    let items = indices.map { outlineView.item(atRow: $0) as! DocumentOutlineItem }
    let menuItems = document?.contextMenuItems(for: items)

    menu.removeAllItems()
    //menuItems?.forEach({
    //
    //})
  }

  // MARK: Support

  func outlineItems(atIndices indices: IndexSet) -> [DocumentOutlineItem] {
    return indices.compactMap { outlineView.item(atRow: $0) as? DocumentOutlineItem }
  }

  @objc func handleContextMenuItem(_ sender: NSMenuItem) {
    let items = outlineItems(atIndices: outlineView.contextMenuIndices)
    document?.projectOutlineMenuSelectedItem(tag: sender.tag, items: items, completion: { addedItems, removedItems in
      self.outlineView.beginUpdates()

      // TODO:
      self.outlineView.endUpdates()
    })
  }
}

extension NSOutlineView {
  // Thanks https://stackoverflow.com/a/65105980/433373
  var contextMenuIndices: IndexSet {
    // TODO: Move menu logic to the Document class (which knows the internals of the model)
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
