//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2022/08/14.
//

import XCTest
import ProjectDocument

final class DocumentTests: XCTestCase {

  func testAutosavesInPlace() {
    XCTAssertTrue(Document.autosavesInPlace)
  }

  

}
