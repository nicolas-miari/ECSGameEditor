//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2022/09/19.
//

import AppKit

/// Handles user selection of input images using the file system's capabilities.
final class ImageFileImporter: NSObject, NSOpenSavePanelDelegate {

  ///
  func openUserSelectedImages() async -> [URL] {
    return await withCheckedContinuation({ continueation in
      self.openUserSelectedImages { images in
        continueation.resume(returning: images)
      }
    })
  }

  ///
  private func openUserSelectedImages(completion: @escaping (_ images: [URL]) -> Void) {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = true
    panel.allowedFileTypes = NSImage.imageTypes
    panel.canChooseFiles = true
    panel.canChooseDirectories = true
    panel.delegate = self

    panel.begin() { (result) in
      guard result == .OK else {
        return
      }
      let boxed: [[URL]] = panel.urls.map {
        guard $0.hasDirectoryPath else {
          return [$0]
        }
        return FileManager.default.contentsOfDirectory(at: $0)
      }
      let urls = boxed.flatMap { $0 }

      completion(urls)
    }
  }

  // MARK: - NSOpenSavePanelDelegate

  func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
    if url.hasDirectoryPath {
      return shouldEnableDirectory(url)
    } else {
      return shouldEnableFile(url)
    }
  }

  // MARK: - File Inspection Support

  private func shouldEnableFile(_ url: URL) -> Bool {
    return url.isImage
  }

  private func shouldEnableDirectory(_ url: URL) -> Bool {
    let contents = FileManager.default.contentsOfDirectory(at: url)
    return contents.contains { $0.isImage }
  }
}


// MARK: - Supporting Extensions

extension FileManager {
  ///
  fileprivate func contentsOfDirectory(at url: URL) -> [URL] {
    guard let contents = try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else {
      return []
    }
    return contents
  }
}

extension URL {
  ///
  fileprivate var isImage: Bool {
    guard let supportedTypes:[CFString] = CGImageSourceCopyTypeIdentifiers() as? [CFString] else {
      return false
    }
    guard let fileUTI: String = try? NSWorkspace.shared.type(ofFile: self.path) else {
      return false
    }
    for uti in supportedTypes {
      // TODO: How is this different from NSImage.imageTypes?
      if UTTypeConformsTo(uti, "public.image" as CFString), UTTypeConformsTo(fileUTI as CFString, uti) {
        return true
      }
    }
    return false
  }
}
