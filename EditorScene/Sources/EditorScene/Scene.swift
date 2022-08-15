import Foundation

import CodableTree
import Component
import Entity
import Transform

public final class Scene: Codable {

  internal var entityTable: [EntityIdentifier: ComponentList]

  /**
   Holds the tree structure implicitly determined by the scene's entities' `Transform` components.

   The root node represents the scene itself. The nodes immediately below belong to two types:
    - Localized: Have a `Transform` component with no parent (their global matrix is the same as the
   local one), and each is the root of a subtree of localized entities.
    - Delocalized: Have no `Transform` component and thus no position within the scene, and can't
   have children. May have other components that govern scene-global state and/or logic.

   Manipulating the tree's nodes directly causes the relationships between the corresponding
   `Transform` components of the represented entities to be updated accordingly.
   */
  internal var tree: Node = Node(name: "Root", children: [])

  // MARK: - Public Interface

  /**
   Creates a new instance.

   The scenes do not know their own unique identifiers; when a document creates a new scene, it also
   creates a unique ID and stores a reference to the new scene in a dictionary, keyed by the ID.
   When the project is archived, the scenes are serialized into subdirectories named after their
   unique IDs, and later read back in.
   */
  public init() {
    entityTable = [:]
  }

  /**
   Creates a new entity in the scene.

   If parentID is `nil` (the default), a **delocalized** entity with no components is created at the
   top level of the scene hierarchy. Otherwise, it is created with a transform component set as
   child of the specified parent's transform.
   */
  func createNewEntity(parentID: EntityIdentifier? = nil) {
    let newID = EntityIdentifier()
    var componentList = ComponentList()
    defer {
      entityTable[newID] = componentList
    }

    guard let parentID = parentID else {
      // Delocalized entity. Also create leaf tree node and attach as child of the root.
      return
    }
    // Localized entity. Also create branch node and attach as child of the parent.
    guard let parent = entityTable[parentID] else {
      fatalError("Entity ID not found.")
    }
    guard let parentTransform = parent.component(ofType: Transform.self) else {
      fatalError("Requested parent entity dfoes not have a transform component")
    }
    let transform = Transform()
    parentTransform.insertChild(transform, at: 0)
    componentList.addComponent(transform)
  }
}

// MARK: - Support

extension Transform: KeyedComponent {}

