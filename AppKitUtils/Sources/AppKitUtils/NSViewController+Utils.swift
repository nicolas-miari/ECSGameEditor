//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2022/09/19.
//

import AppKit

extension NSViewController {

  public static var defaultStorboardName: String {
    return Self.className().replacingOccurrences(of: "ViewController", with: "")
  }

  public static func fromStoryboard(name: String = defaultStorboardName) -> Self {
    let storyboard = NSStoryboard(name: name, bundle: Bundle(for: self))
    let initialController = storyboard.instantiateInitialController()
    guard let controller = initialController as? Self else {
      let expectedType = String(describing: self)
      let actualTypeName = String(describing: type(of: initialController))
      fatalError("Storyboard inconsistency: Initial view controller of storyboard '\(name)' expected to be of type \(expectedType)), found \(actualTypeName) instead.")
    }
    return controller
  }
}
