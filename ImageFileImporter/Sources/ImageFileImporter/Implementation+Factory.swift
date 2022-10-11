//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2022/10/08.
//

import AppKit

// MARK: - Factory

public final class ImageFileImporterFactory {

  @MainActor public static func newFileImporter() -> some ImageFileImporter {
    return ImageFileImporterImplementation()
  }
}

// MARK: - Default implementation

/// The class is marked with main actor so that its interface can be async and also work with the UI
/// thread.
@MainActor
private final class ImageFileImporterImplementation: NSObject, NSOpenSavePanelDelegate, ImageFileImporter {

  /// MARK: ImageFileImporter

  fileprivate func openUserSelectedImages() async -> [URL] {
    return await withCheckedContinuation({ continueation in
      self.openUserSelectedImages { images in
        continueation.resume(returning: images)
      }
    })
  }

  /// MARK: -

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

  /// Non-isolated to satisfy protocol requirements.
  nonisolated fileprivate func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
    if url.hasDirectoryPath {
      return shouldEnableDirectory(url)
    } else {
      return shouldEnableFile(url)
    }
  }

  // MARK: - File Inspection Support

  /// Non-isolated to interoperate with delegate methd `panel(_:shouldEnable:)`.
  nonisolated fileprivate func shouldEnableFile(_ url: URL) -> Bool {
    return url.isImage
  }

  /// Non-isolated to interoperate with delegate methd `panel(_:shouldEnable:)`.
  nonisolated fileprivate func shouldEnableDirectory(_ url: URL) -> Bool {
    return true
    //let contents = FileManager.default.contentsOfDirectory(at: url)
    //return contents.contains { $0.isImage }
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
