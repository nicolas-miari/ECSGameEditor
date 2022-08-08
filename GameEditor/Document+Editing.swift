//
//  Document+Editing.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Foundation
import CodableTree

extension Document {

  
}

struct NodeMoveOperation {
  let srcIndex: Int
  let srcParent: Node
  let dstIndex: Int
  let dstParent: Node

  func reversed() -> NodeMoveOperation {
    return NodeMoveOperation(srcIndex: dstIndex, srcParent: dstParent, dstIndex: srcIndex, dstParent: srcParent)
  }
}
