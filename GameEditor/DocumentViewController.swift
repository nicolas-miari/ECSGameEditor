//
//  DocumentViewController.swift
//  GameEditor
//
//  Created by Nicolás Miari on 2022/08/07.
//

import Cocoa

class DocumentViewController: NSViewController {

  var document: Document? {
    return view.window?.windowController?.document as? Document
  }
}
