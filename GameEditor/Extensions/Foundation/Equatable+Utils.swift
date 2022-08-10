//
//  Equatable+Utilsd.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/10.
//

import Foundation

extension Equatable {

  func notIn(_ array: [Self]) -> Bool {
    return !array.contains(self)
  }

  func isIn(_ array: [Self]) -> Bool {
    return array.contains(self)
  }
}
