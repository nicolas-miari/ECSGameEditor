//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2022/08/14.
//

import Foundation
import CodableTree
import Scene

/**
 A concrete class that wraps the project hierarchy's model objects, for use by the view layer.

 The specific model objects wrapped are private, and accessible only to the Document class;

 Equatable Conformance: Two instances compare as equal if they both wrap same opaque object (the
 types of which must conform to `DocumentItem`, and hence `AnyObject`).
*/
public final class DocumentOutlineItem: Equatable {

  // MARK: - Exposed Interface

  // The title text to use when displaying the item.
  public var title: String {
    return contents.name
  }

  public var imageName: String {
    return "" // TODO: Implement
  }

  public static func == (lhs: DocumentOutlineItem, rhs: DocumentOutlineItem) -> Bool {
    /**
     Both wrapped objects might be of different concrete types, but they're guaranteed to be of
     reference types by the `AnyObject` constraint on `DocumentItem` to which they both conform; so
     we can compare the memory addresses directly for equality:
     */
    return (lhs.contents as AnyObject) === (rhs.contents as AnyObject)
  }

  /**
   The wrapped object. It can be of any type that conforms to `DocumentItem`.

   This property is internal, because the wrapped object and its type should be opaque to the
   clients of the class (the view layer).
   */
  internal let contents: any DocumentItem

  /**
   Creates an instance wrapping a model object.

   This initializer is internal, because the wrapped object and its type should be opaque to the
   clients of the class (the view layer).
   */
  internal init(contents: any DocumentItem) {
    self.contents = contents
  }
}

// MARK: - Internal Support

/**
 A type that can represent a model object in the project hierarchy.

 Conformance to this protocol by all model types enables wraooing them in the modelview class
 `DocumentOutlineItem` before handling them to the view layer, from where only essential attributes
 for display are accessible.
 */
internal protocol DocumentItem: AnyObject, Equatable {
  var name: String { get }
}

extension Node: DocumentItem {}

extension Scene: DocumentItem {
  var name: String {
    return ""
  }

  public static func == (lhs: Scene, rhs: Scene) -> Bool {
    return false
  }
}
