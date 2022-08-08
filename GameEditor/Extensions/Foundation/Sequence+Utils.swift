//
//  Sequence+Utils.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/08.
//

import Foundation

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
