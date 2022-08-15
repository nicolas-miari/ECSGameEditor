import AppKit

public struct DocumentOutlineViewModel {

  public let title: String

  public let image: NSImage

  public let tintColor: NSColor

  init(title: String, icon: OutlineIcon) {
    self.title = title
    self.image = icon.image
    self.image.isTemplate = true
    self.tintColor = icon.tintColor
  }
}

public enum OutlineIcon {
  //case root
  case folder
  case asset
  case scene
  case entity

  fileprivate var image: NSImage {
    switch self {
    //case .root:
    //  return NSImage(systemSymbolName: "", accessibilityDescription: nil)!
    case .folder:
      return NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)!
    case .asset:
      return NSImage(systemSymbolName: "character.book.closed.fill", accessibilityDescription: nil)!
    case .scene:
      return NSImage(systemSymbolName: "rectangle", accessibilityDescription: nil)!
    case .entity:
      return NSImage(systemSymbolName: "cube.fill", accessibilityDescription: nil)!
    }
  }

  fileprivate var tintColor: NSColor {
    switch self {
    case .folder:
      return NSColor(calibratedRed: 25.0/255.0, green: 181.0/255.0, blue: 1, alpha: 1)
    case .asset:
      return NSColor.systemPink
    case .scene:
      return NSColor.systemGreen
    case .entity:
      return NSColor.systemYellow
    }
  }
}
