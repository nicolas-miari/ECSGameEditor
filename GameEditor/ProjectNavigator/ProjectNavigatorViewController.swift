//
//  ProjectNavigatorViewController.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import AppKit
import ProjectDocument

/**
 How to set pane width: https://stackoverflow.com/a/41317631/433373
 */
class ProjectNavigatorViewController: DocumentViewController {

  @IBOutlet private weak var outlineView: NSOutlineView!

  private var draggetOutlineItems: [DocumentOutlineItem]?
  private let contextMenu = NSMenu(title: "Context")

  // MARK: - NSViewController

  override func viewDidLoad() {
    super.viewDidLoad()

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
    guard let document = document else {
      return nil
    }
    let viewModel = document.viewModel(forItem: item)

    guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("NameCell"), owner: self) as? NSTableCellView else {
      return nil
    }

    if let textField = view.textField {
      textField.stringValue = viewModel.title
      textField.sizeToFit()
    }
    if let imageView = view.imageView {
      let configuration = NSImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .small)
      imageView.image = viewModel.image.withSymbolConfiguration(configuration)
      imageView.contentTintColor = viewModel.tintColor
    }
    return view
  }
}

// MARK: - NSMenu Delegate

extension ProjectNavigatorViewController: NSMenuDelegate {
  // Thanks https://stackoverflow.com/a/65105980/433373
  func menuNeedsUpdate(_ menu: NSMenu) {
    menu.removeAllItems()
    /*
    let indices = outlineView.contextMenuIndices
    let items = indices.map { outlineView.item(atRow: $0) as! DocumentOutlineItem }
    let menuItemDescriptors = document?.menuItemDescriptors(for: items) ?? []
    let menuItems = self.menuItems(from: menuItemDescriptors)
    menu.items = menuItems
     */
  }

  // MARK: Support

  func menuItems(from descriptors: [Document.MenuItemDescriptor]) -> [NSMenuItem] {
    return descriptors.map {
      switch $0.itemType {
      case .action(let tag):
        let item = NSMenuItem(title: $0.title, action: #selector(handleContextMenuItem(_:)), keyEquivalent: "")
        item.tag = tag.rawValue
        return item

      case .submenu(let children):
        let item = NSMenuItem(title: $0.title, action: nil, keyEquivalent: "")
        // Create item's submenu by recursing on children:
        item.submenu = NSMenu(title: $0.title, items: menuItems(from: children))
        return item

      case .separator:
        return NSMenuItem.separator()
      }
    }
  }

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

extension NSMenu {
  convenience init(title: String, items: [NSMenuItem]) {
    self.init(title: title)
    self.items = items
  }
}
